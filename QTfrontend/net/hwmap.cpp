/*
 * Hedgewars, a free turn based strategy game
 * Copyright (c) 2006-2007 Ulyanov Igor <iulyanov@gmail.com>
 * Copyright (c) 2004-2013 Andrey Korotaev <unC0Rr@gmail.com>
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

#include "hwconsts.h"
#include "hwmap.h"

HWMap::HWMap(QObject * parent) :
    TCPBase(false, parent)
{
}

HWMap::~HWMap()
{
}

bool HWMap::couldBeRemoved()
{
    return !m_hasStarted;
}

void HWMap::getImage(const QString & seed, int filter, MapGenerator mapgen, int maze_size, const QByteArray & drawMapData)
{
    m_seed = seed;
    templateFilter = filter;
    m_mapgen = mapgen;
    m_maze_size = maze_size;
    if(mapgen == MAPGEN_DRAWN) m_drawMapData = drawMapData;
    Start(true);
}

QStringList HWMap::getArguments()
{
    QStringList arguments;
    arguments << "--internal";
    arguments << "--port";
    arguments << QString("%1").arg(ipc_port);
    arguments << "--user-prefix";
    arguments << cfgdir->absolutePath();
    arguments << "--landpreview";
    return arguments;
}

void HWMap::onClientDisconnect()
{
    if (readbuffer.size() == 128 * 32 + 1)
    {
        quint8 *buf = (quint8*) readbuffer.constData();
        QImage im(buf, 256, 128, QImage::Format_Mono);
        im.setNumColors(2);
        emit HHLimitReceived(buf[128 * 32]);
        emit ImageReceived(im);
    }
}

void HWMap::SendToClientFirst()
{
    SendIPC(QString("eseed %1").arg(m_seed).toUtf8());
    SendIPC(QString("e$template_filter %1").arg(templateFilter).toUtf8());
    SendIPC(QString("e$mapgen %1").arg(m_mapgen).toUtf8());

    switch (m_mapgen)
    {
        case MAPGEN_MAZE:
            SendIPC(QString("e$maze_size %1").arg(m_maze_size).toUtf8());
            break;

        case MAPGEN_DRAWN:
        {
            QByteArray data = m_drawMapData;
            while(data.size() > 0)
            {
                QByteArray tmp = data;
                tmp.truncate(200);
                SendIPC("edraw " + tmp);
                data.remove(0, 200);
            }
            break;
        }
        default:
            ;
    }

    SendIPC("!");
}
