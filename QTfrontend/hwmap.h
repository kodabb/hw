/*
 * Hedgewars, a free turn based strategy game
 * Copyright (c) 2006 Igor Ulyanov <iulyanov@gmail.com>
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

#ifndef _HWMAP_INCLUDED
#define _HWMAP_INCLUDED

#include <QByteArray>
#include <QString>
#include <QImage>

#include "tcpBase.h"

#include <string>

class HWMap : public TCPBase
{
  Q_OBJECT
    
 public:
  HWMap();
  virtual ~HWMap();
  void getImage(std::string seed);

 protected:
  virtual QStringList setArguments();
  virtual void onClientDisconnect();
  virtual void SendToClientFirst();

 signals:
  void ImageReceived(const QImage newImage);

 private:
  std::string m_seed;

 private slots:
};

#endif // _HWMAP_INCLUDED
