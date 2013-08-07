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

#include <ShlObj.h>
#include <QDir>
#include <QDebug>

#include <libtorrent/lazy_entry.hpp>
#include <libtorrent/error_code.hpp>

#include "bittorrentimporter.h"
#include "misc.h"

BittorrentImporter::BittorrentImporter(const QString &path, bool bittorrent) : BaseImporter() {
  m_path = QDir::fromNativeSeparators(path);
  ut_bt_append = bittorrent ? "BitTorrent/" : "uTorrent/";
  m_filenames << "resume.dat" << "resume.dat.old";
}

BittorrentImporter::~BittorrentImporter() {}

void BittorrentImporter::autodetectImportSourcePath() {
  if (!m_path.isEmpty())
    return;

  m_path += baseImportPath();
  foreach (const QString &name, m_filenames) {
    if (BaseImporter::isValidSourceItem(m_path + name)) {
      m_path += name;
      emit autodetectSuccess(m_path);
      return;
    }
  }

  emit autodetectFailure();
}

const QString BittorrentImporter::baseImportPath() const {
  QString ret;

#ifdef Q_OS_WIN
  LPWSTR path=new WCHAR[256];
  if (SHGetSpecialFolderPath(0, path, CSIDL_APPDATA, FALSE))
    ret = QDir::fromNativeSeparators(QString::fromWCharArray(path));
  else
    return QString();

  ret += '/' + ut_bt_append;
#endif

  return ret;
}

void BittorrentImporter::beginImport() {
  Q_ASSERT(!m_path.isEmpty());
  qDebug() << "Importing from file: " + m_path;

  QFile f;
  f.setFileName(m_path);
  f.open(QFile::ReadOnly);
  QByteArray array = f.readAll();
  f.close();
  const char *buf = array.constData();

  libtorrent::lazy_entry e;
  libtorrent::error_code ec;

  libtorrent::lazy_bdecode(buf, buf + array.size() + 1, e, ec);
  if (ec.value() != libtorrent::errors::no_error) {
    qDebug() << "Decoding uTorrent/BitTorrent resume file failed, reason: " << misc::toQString(ec.message());
    emit importFailure(tr("Decoding uTorrent/BitTorrent resume file failed.\n Reason: ") + misc::toQStringU(ec.message()));
    return;
  }

  if (e.type() != libtorrent::lazy_entry::dict_t) {
    emit importFailure(tr("Decoding was successful, but file type was incorrect"));
    return;
  }

  // Actually parse data
  for (int i = 0; i < e.dict_size(); ++i) {
    std::pair<std::string, const libtorrent::lazy_entry *> dict =  e.dict_at(i);
    if (dict.second->type() != libtorrent::lazy_entry::dict_t) // Ignore entries, which are not dicts (e.g. '.fileguard' entry)
      continue;

    const libtorrent::lazy_entry* torrent = dict.second;
    QString file = QDir::fromNativeSeparators(misc::toQStringU(dict.first)); // .torrent file
    if (!file.contains('/')) { // TODO: make sure we really need that, might be a redundant check
      // Looks like a relative path to .torrent file, merge with source path
      file.insert(0, m_path.left(m_path.lastIndexOf('/') + 1));
    }
    if (!BaseImporter::isValidSourceItem(file)) {
      qDebug() << ".torrent doesn't exist or can't be read: " << file;
      continue;
    }

    QString name = misc::toQStringU(torrent->dict_find_string_value("caption")); // Torrent name
    QString save_path = QDir::fromNativeSeparators(misc::toQStringU(torrent->dict_find_string_value("path"))); // Save path
    int finished = torrent->dict_find_int_value("completed_on");

    // File priorities (at this point we only care about DONT_DOWNLOAD; High, Med, Low are treated as Med)
    // uTorrent's prio is a char array, one byte per file. Order corresponds to file order in .torrent
    // Values for prio byte:
    // 0x80 - Don't download        - 0 qBt
    // 0x04 - Low priority        \
    // 0x08 - Medium priority      -- 1 qBt
    // 0x0C - High priority       /
    std::string _prioStr = torrent->dict_find_string_value("prio");
    std::vector<char> prio(_prioStr.begin(), _prioStr.end());
    if (prio.empty()) {
      qDebug() << "Priorities are emtpy, torrent: " << file;
      continue;
    }
    std::vector<char>::iterator it = prio.begin();
    std::vector<char>::iterator itend = prio.end();
    std::vector<ushort> p;
    for (; it < itend; ++it) {
      uchar a = *it;
      if ((uchar)*it == 0x80)
        p.push_back(0);
      else
        p.push_back(1);
    }

    importEntry entry;
    entry.torrent_path = file;
    entry.name = name;
    entry.save_path = save_path;
    entry.complete = finished;
    entry.prio = p;

    m_list << entry;
  }

  emit importSuccess(m_list);
}
