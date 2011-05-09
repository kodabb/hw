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
#include <QPushButton>
#include <QComboBox>

#include "pagecampaign.h"

PageCampaign::PageCampaign(QWidget* parent) : AbstractPage(parent)
{
    QGridLayout * pageLayout = new QGridLayout(this);
    pageLayout->setColumnStretch(0, 1);
    pageLayout->setColumnStretch(1, 2);
    pageLayout->setColumnStretch(2, 1);
    pageLayout->setRowStretch(0, 1);
    pageLayout->setRowStretch(3, 1);

    CBSelect = new QComboBox(this);
    CBTeam = new QComboBox(this);

    pageLayout->addWidget(CBTeam, 1, 1);
    pageLayout->addWidget(CBSelect, 2, 1);
    
    BtnStartCampaign = new QPushButton(this);
    BtnStartCampaign->setFont(*font14);
    BtnStartCampaign->setText(QPushButton::tr("Go!"));
    pageLayout->addWidget(BtnStartCampaign, 2, 2);

    BtnBack = addButton(":/res/Exit.png", pageLayout, 4, 0, true);
}
