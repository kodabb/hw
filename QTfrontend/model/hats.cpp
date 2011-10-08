/*
 * Hedgewars, a free turn based strategy game
 * Copyright (c) 2008-2011 Andrey Korotaev <unC0Rr@gmail.com>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 2 of the License
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA
 */

#include <QDir>
#include <QPixmap>
#include <QPainter>
#include "hwconsts.h"
#include "hwform.h"
#include "hats.h"

HatsModel::HatsModel(QObject* parent) :
  QAbstractListModel(parent)
{
    QFile hhfile;
    hhfile.setFileName(cfgdir->absolutePath() + "/Data/Graphics/Hedgehog/Idle.png");
    if (!hhfile.exists()) hhfile.setFileName(datadir->absolutePath() + "/Graphics/Hedgehog/Idle.png");
    QPixmap hhpix = QPixmap(QFileInfo(hhfile).absoluteFilePath()).copy(0, 0, 32, 32);

    QDir tmpdir;
    tmpdir.cd(cfgdir->absolutePath());
    tmpdir.cd("Data");
    tmpdir.cd("Graphics");
    tmpdir.cd("Hats");

    tmpdir.setFilter(QDir::Files);

    QStringList userhatsList = tmpdir.entryList(QStringList("*.png"));
    for (QStringList::Iterator it = userhatsList.begin(); it != userhatsList.end(); ++it )
    {
        QString str = QString(*it).replace(QRegExp("^(.*)\\.png"), "\\1");
        QPixmap pix(cfgdir->absolutePath() + "/Data/Graphics/Hats/" + str + ".png");

        QPixmap tmppix(32, 37);
        tmppix.fill(QColor(Qt::transparent));

        QPainter painter(&tmppix);
        painter.drawPixmap(QPoint(0, 5), hhpix);
        painter.drawPixmap(QPoint(0, 0), pix.copy(0, 0, 32, 32));
        if(pix.width() > 32)
            painter.drawPixmap(QPoint(0, 0), pix.copy(32, 0, 32, 32));
        painter.end();

        hats.append(qMakePair(str, QIcon(tmppix)));
    }

    tmpdir.cd(datadir->absolutePath());
    tmpdir.cd("Graphics");
    tmpdir.cd("Hats");

    QStringList hatsList = tmpdir.entryList(QStringList("*.png"));
    for (QStringList::Iterator it = hatsList.begin(); it != hatsList.end(); ++it )
    {
        if (userhatsList.contains(*it,Qt::CaseInsensitive)) continue;
        QString str = (*it).replace(QRegExp("^(.*)\\.png"), "\\1");
        QPixmap pix(datadir->absolutePath() + "/Graphics/Hats/" + str + ".png");

        QPixmap tmppix(32, 37);
        tmppix.fill(QColor(Qt::transparent));

        QPainter painter(&tmppix);
        painter.drawPixmap(QPoint(0, 5), hhpix);
        painter.drawPixmap(QPoint(0, 0), pix.copy(0, 0, 32, 32));
        if(pix.width() > 32)
            painter.drawPixmap(QPoint(0, 0), pix.copy(32, 0, 32, 32));
        painter.end();

        hats.append(qMakePair(str, QIcon(tmppix)));
    }
    // Reserved hats
    tmpdir.cd("Reserved");
    hatsList = tmpdir.entryList(QStringList(playerHash+"*.png"));
    for (QStringList::Iterator it = hatsList.begin(); it != hatsList.end(); ++it )
    {
        QString str = (*it).replace(QRegExp("^(.*)\\.png"), "\\1");
        QPixmap pix(datadir->absolutePath() + "/Graphics/Hats/Reserved/" + str + ".png");

        QPixmap tmppix(32, 37);
        tmppix.fill(QColor(Qt::transparent));

        QPainter painter(&tmppix);
        painter.drawPixmap(QPoint(0, 5), hhpix);
        painter.drawPixmap(QPoint(0, 0), pix.copy(0, 0, 32, 32));
        painter.end();

        hats.append(qMakePair("Reserved "+str.remove(0,32), QIcon(tmppix)));
    }
}

QVariant HatsModel::headerData(int section,
            Qt::Orientation orientation, int role) const
{
    Q_UNUSED(section);
    Q_UNUSED(orientation);
    Q_UNUSED(role);

    return QVariant();
}

int HatsModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid())
        return 0;
    else
        return hats.size();
}

/*int HatsModel::columnCount(const QModelIndex & parent) const
{
    if (parent.isValid())
        return 0;
    else
        return 2;
}
*/
QVariant HatsModel::data(const QModelIndex &index,
                         int role) const
{
    if (!index.isValid() || index.row() < 0
        || index.row() >= hats.size()
        || (role != Qt::DisplayRole && role != Qt::DecorationRole))
        return QVariant();

    if (role == Qt::DisplayRole)
        return hats.at(index.row()).first;
    else // role == Qt::DecorationRole
        return hats.at(index.row()).second;
}
