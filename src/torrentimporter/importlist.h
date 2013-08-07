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

#ifndef IMPORTLIST_H
#define IMPORTLIST_H

#include <QTreeWidget>
#include <QPair>

#include "baseimporter.h"

class ImportList : public QTreeWidget {
  Q_OBJECT
  Q_DISABLE_COPY(ImportList)

public:
  enum ImportColumns {
    COL_CHECK,
    COL_NAME,
    COL_COMPLETE,
    COL_RECHECK
  };

  explicit ImportList(QWidget *parent = 0);
  void loadImportList(const QList<importEntry> list, bool include_incomplete = false);
  QList<importEntry> getImportList() const;
  ~ImportList();

private:
  QList<importEntry> m_imports;
  QList<QTreeWidgetItem*> m_items;

  void clear();
  void loadSettings();
  void saveSettings() const;
//  void clear();
};

#endif // IMPORTLIST_H
