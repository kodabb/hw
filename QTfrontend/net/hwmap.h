/*
 * Hedgewars, a free turn based strategy game
 * Copyright (c) 2006 Igor Ulyanov <iulyanov@gmail.com>
 * Copyright (c) 2004-2014 Andrey Korotaev <unC0Rr@gmail.com>
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
 * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
 */

#ifndef _HWMAP_INCLUDED
#define _HWMAP_INCLUDED

#include <QByteArray>
#include <QString>
#include <QImage>

#include "tcpBase.h"

enum MapGenerator
{
    MAPGEN_REGULAR,
    MAPGEN_MAZE,
    MAPGEN_DRAWN,
    MAPGEN_MAP
};

class HWMap : public TCPBase
{
        Q_OBJECT

    public:
        HWMap(QObject *parent = 0);
        virtual ~HWMap();
        void getImage(const QString & seed, int templateFilter, MapGenerator mapgen, int maze_size, const QByteArray & drawMapData);
        bool couldBeRemoved();

    protected:
        virtual QStringList getArguments();
        virtual void onClientDisconnect();
        virtual void SendToClientFirst();

    signals:
        void ImageReceived(const QImage newImage);
        void HHLimitReceived(int hhLimit);

    private:
        QString m_seed;
        int templateFilter;
        MapGenerator m_mapgen;
        int m_maze_size;
        QByteArray m_drawMapData;

    private slots:
};

#endif // _HWMAP_INCLUDED
