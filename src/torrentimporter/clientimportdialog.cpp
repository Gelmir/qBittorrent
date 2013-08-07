/*
 * Bittorrent Client using Qt4 and libtorrent.
 * Copyright (C) 2013  Nick Tiskov
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 *
 * In addition, as a special exception, the copyright holders give permission to
 * link this program with the OpenSSL project's "OpenSSL" library (or with
 * modified versions of it that use the same license as the "OpenSSL" library),
 * and distribute the linked executables. You must obey the GNU General Public
 * License in all respects for all of the code used other than "OpenSSL".  If you
 * modify file(s), you may extend this exception to your version of the file(s),
 * but you are not obligated to do so. If you do not wish to do so, delete this
 * exception statement from your version.
 *
 * Contact : daymansmail@gmail.com
 */

#include <QDebug>
#include <QDir>
#include <QMessageBox>
#include <QFileDialog>
#include <QLayout>

#include <qinisettings.h>
#include "clientimportdialog.h"
#include "ui_clientimportdialog.h"

#include "bittorrentimporter.h"

void ClientImportDialog::beginImport(QWidget *parent) {
  ClientImportDialog dlg(parent);
  dlg.exec();
}

ClientImportDialog::ClientImportDialog(QWidget *parent) : QDialog(parent), ui(new Ui::ClientImportDialog) {
  ui->setupUi(this);
  initUI();

  model = new ImportList(this);

  connect(ui->comboSource, SIGNAL(currentIndexChanged(int)), SLOT(sourceChanged()));
  connect(ui->pushPathBrowse, SIGNAL(clicked()), SLOT(browseFilesystem()));
  connect(ui->checkIncludeIncomplete, SIGNAL(clicked()), SLOT(sourceChanged()));
  connect(ui->buttonBox, SIGNAL(accepted()), SLOT(saveSettings()));
  connect(ui->buttonBox, SIGNAL(rejected()), SLOT(saveSettings()));
}

ClientImportDialog::~ClientImportDialog() {
  delete model;
  delete ui;
}

void ClientImportDialog::showEvent(QShowEvent *e) {
  QDialog::showEvent(e);
  loadSettings();
  static_cast<QBoxLayout*>(layout())->insertWidget(layout()->indexOf(ui->checkIncludeIncomplete) + 1, model);
}

void ClientImportDialog::closeEvent(QCloseEvent *e) {
  QDialog::closeEvent(e);
  saveSettings();
}

void ClientImportDialog::sourceChanged() {
  if (ui->comboSource->currentIndex() == 0)
    return;

  ClientImportDialog::SupportedImports iType = (ClientImportDialog::SupportedImports)ui->comboSource->currentIndex();
  if (iType == ClientImportDialog::UTORRENT) {
    BittorrentImporter imp(ui->linePath->text());
    importerConnect(&imp);
    imp.autodetectImportSourcePath();
    imp.beginImport();
  }
}

void ClientImportDialog::browseFilesystem() {
  if (ui->comboSource->currentIndex() == 0) {
    QMessageBox::information(this, tr("No import source selected"),
                             tr("Please select import source first."), QMessageBox::Ok);
    return;
  }

  QString path;
  QStringList names;
  QString base_path;
  QString dlg_filter = "(";
  ClientImportDialog::SupportedImports iType = (ClientImportDialog::SupportedImports)ui->comboSource->currentIndex();
  if (iType == ClientImportDialog::UTORRENT) {
    BittorrentImporter imp;
    names = imp.expectedFilenames();
    base_path = imp.baseImportPath();
  }
  foreach (const QString &str, names) {
    dlg_filter += str + ' ';
  }
  dlg_filter = dlg_filter.trimmed() + ')';
  path = QDir::fromNativeSeparators(QFileDialog::getOpenFileName(this, QString(), base_path, dlg_filter, 0, QFileDialog::ReadOnly));
  if (!path.isEmpty()) {
    if (BaseImporter::isValidSourceItem(path))
      handleAutoDetectSuccess(path);
  }

}

void ClientImportDialog::handleAutoDetectFailure() {
  QMessageBox::warning(this, tr("Autodetection failure"),
                       tr("Failed to automatically detect import path.\nPlease select path manually"), QMessageBox::Ok);
  ui->linePath->clear();
}

void ClientImportDialog::handleAutoDetectSuccess(const QString path) {
  ui->linePath->setText(QDir::toNativeSeparators(path));
}

void ClientImportDialog::handleImportFailure(const QString reason) {
  QMessageBox::critical(this, tr("Import failure"), reason, QMessageBox::Ok);
  m_imports.clear();
  ui->linePath->clear();
  ui->comboSource->setCurrentIndex(0);
}

void ClientImportDialog::handleImportSuccess(QList<importEntry> list) {
  m_imports.clear();
  m_imports = list;
  // Populate model
  // [ selection checkbox ] : [ name ] : [ complete icon + tooltip ] : [ force recheck checkbox ]
  // There are three completion states:
  // 1. Completed: all files have been DLed
  // 2. Completed (partial file selection):
  //          torrent has completed, but not all files in torrent were selected (force recheck checked and locked)
  // 3. Incomplete: torrent hasn't been downloaded (force recheck checked and locked)
  model->loadImportList(m_imports, ui->checkIncludeIncomplete->isChecked());
}

void ClientImportDialog::importerConnect(const QObject *sender) const {
  const BaseImporter *b = qobject_cast<const BaseImporter*>(sender);
  connect(b, SIGNAL(autodetectFailure()), SLOT(handleAutoDetectFailure()));
  connect(b, SIGNAL(autodetectSuccess(QString)), SLOT(handleAutoDetectSuccess(QString)));
  connect(b, SIGNAL(importFailure(QString)), SLOT(handleImportFailure(QString)));
  connect(b, SIGNAL(importSuccess(QList<importEntry>)), SLOT(handleImportSuccess(QList<importEntry>)));
}

void ClientImportDialog::initUI() {
  types[ClientImportDialog::BITTORRENT] = QString::fromUtf8("Bittorrent");
  types[ClientImportDialog::UTORRENT] = QString::fromUtf8("µTorrent");

  ui->comboSource->insertItem(0, tr("Select import source"));
  ui->comboSource->insertItem(ClientImportDialog::BITTORRENT, types[ClientImportDialog::BITTORRENT]);
  ui->comboSource->insertItem(ClientImportDialog::UTORRENT, types[ClientImportDialog::UTORRENT]);
}

void ClientImportDialog::loadSettings() {
  QIniSettings settings;
  if (!restoreGeometry(settings.value("ClientImport/geometry").toByteArray()))
    qDebug() << "Fail";
}

void ClientImportDialog::saveSettings() const {
  QIniSettings settings;
  settings.setValue("ClientImport/geometry", saveGeometry());
}
