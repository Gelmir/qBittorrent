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

#include <QHeaderView>
#include <QStringList>

#include "importlist.h"
#include "qinisettings.h"
#include "iconprovider.h"

ImportList::ImportList(QWidget *parent) : QTreeWidget(parent) {
  setRootIsDecorated(false);
  setAllColumnsShowFocus(true);
  setItemsExpandable(false);
  setSelectionMode(QAbstractItemView::NoSelection);

  QStringList header;
  header << "" <<
            tr("Torrent name") <<
            tr("Compete") <<
            tr("Force recheck");

  setHeaderItem(new QTreeWidgetItem(header));

  loadSettings();
}

ImportList::~ImportList() {
  saveSettings();
  clear();
}

void ImportList::loadImportList(const QList<importEntry> list, bool include_incomplete) {
  clear();
  foreach (importEntry e, list) {
    bool complete = e.complete;
    QString icon = "dialog-ok-apply-icon";
    QString tp = tr("Torrent is ready for import");

    if (!complete && !include_incomplete)
      continue;

    std::vector<ushort> prio = e.prio;
    std::vector<ushort>::const_iterator it = prio.cbegin();
    std::vector<ushort>::const_iterator itend = prio.cend();
    for ( ; it < itend ; ++it) {
      if (*it == 0) {
        if (complete) {
          icon = "dialog-warning";
          tp = tr("Torrent partially finished (not all files have been downloaded): recheck will be forced");
        }
        else {
          icon = "view-refresh";
          tp = tr("Torrent hasn't finished downloading: recheck will be forced");
        }
        e.recheck = true;
        break;
      }
    }

    QTreeWidgetItem *item = new QTreeWidgetItem();
    m_items << item;
    m_imports << e;
    item->setCheckState(COL_CHECK, Qt::Checked);
    item->setText(COL_NAME, e.name);
    item->setIcon(COL_COMPLETE, IconProvider::instance()->getIcon(icon));
    item->setToolTip(COL_COMPLETE, tp);
    item->setCheckState(COL_RECHECK, e.recheck ? Qt::Checked : Qt::Unchecked);
  }

  addTopLevelItems(m_items);
}

QList<importEntry> ImportList::getImportList() const {
  QList<importEntry> entries;
  Q_ASSERT(m_imports.size() == m_items.size());
  for (int i = 0; i < m_items.size(); ++i){
    QTreeWidgetItem* item = m_items.at(i);
    importEntry e = m_imports.at(i);

    if (item->checkState(COL_CHECK) == Qt::Checked) {
      if (!e.recheck && item->checkState(COL_RECHECK) == Qt::Checked)
        e.recheck = true;
      entries << e;
      continue;
    }
  }

  return entries;
}

void ImportList::clear() {
  qDeleteAll(m_items);
  m_items.clear();
  m_imports.clear();
}

void ImportList::loadSettings() {
  QIniSettings settings;
  header()->restoreState(settings.value("ClientImport/ListState").toByteArray());
}

void ImportList::saveSettings() const {
  QIniSettings settings;
  settings.setValue("ClientImport/ListState", header()->saveState());
}
