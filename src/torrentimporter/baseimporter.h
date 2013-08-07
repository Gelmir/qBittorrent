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

#ifndef BASEIMPORTER_H
#define BASEIMPORTER_H

#include <vector>

#include <QObject>
#include <Qlist>
#include <QString>
#include <QStringList>

struct importEntry {
  QString name;
  QString torrent_path;
  QString save_path;
  std::vector<ushort> prio; // Used instead of file list
  bool complete;
  bool recheck; // Don't touch this field yourself
  importEntry() { complete = false; recheck = false; }
};

class BaseImporter : public QObject {
  Q_OBJECT

signals:
  void importSuccess(QList<importEntry> list);
  void importFailure(const QString reason);
  void autodetectSuccess(const QString path);
  void autodetectFailure();

public:
  virtual ~BaseImporter();
  virtual void autodetectImportSourcePath() = 0;
  virtual const QString baseImportPath() const = 0;
  virtual void beginImport() = 0;

  QStringList expectedFilenames() const;
  const QString importSourcePath() const;
  static bool isValidSourceItem(const QString& path);

protected:
  BaseImporter();

  QStringList m_filenames;
  QString m_path;
  QList<importEntry> m_list;
};

#endif // BASEIMPORTER_H
