/*
 * Hedgewars, a free turn based strategy game
 * Copyright (c) 2006-2011 Andrey Korotaev <unC0Rr@gmail.com>
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

#include <QGridLayout>
#include <QHBoxLayout>
#include <QPushButton>

#include "pageinfo.h"
#include "about.h"

QLayout * PageInfo::bodyLayoutDefinition()
{
    QGridLayout * pageLayout = new QGridLayout();

    pageLayout->setColumnStretch(0, 1);
    pageLayout->setColumnStretch(1, 1);
    pageLayout->setColumnStretch(2, 1);

    about = new About();
    pageLayout->addWidget(about, 0, 0, 1, 3);

    return pageLayout;
}

QLayout * PageInfo::footerLayoutDefinition()
{
    QHBoxLayout * bottomLayout = new QHBoxLayout();
    BtnSnapshots = addButton(":/res/Star.png", bottomLayout, 0, true);
    bottomLayout->setAlignment(BtnSnapshots, Qt::AlignRight | Qt::AlignVCenter);
    return bottomLayout;
}

void PageInfo::connectSignals()
{
    //TODO
}

PageInfo::PageInfo(QWidget* parent) : AbstractPage(parent)
{
    initPage();
}

