/*
 * Hedgewars, a free turn based strategy game
 * Copyright (c) 2006, 2007 Ulyanov Igor <iulyanov@gmail.com>
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

#include <QResizeEvent>
#include <QCoreApplication>
#include <QDebug>

#include "frameTeam.h"
#include "teamselhelper.h"
#include "hwconsts.h"

FrameTeams::FrameTeams(QWidget* parent) :
  QWidget(parent), maxHedgehogsPerGame(18), overallHedgehogs(0), mainLayout(this), nonInteractive(false)
{
  mainLayout.setSpacing(1);

  availableColors.push_back(*color1);
  availableColors.push_back(*color2);
  availableColors.push_back(*color3);
  availableColors.push_back(*color4);
  availableColors.push_back(*color5);
  availableColors.push_back(*color6);

  resetColors();
}

void FrameTeams::setNonInteractive()
{
  nonInteractive=true;
  for(tmapTeamToWidget::iterator it=teamToWidget.begin(); it!=teamToWidget.end(); ++it) {
    TeamShowWidget* pts=dynamic_cast<TeamShowWidget*>(it.value());
    if(!pts) throw;
    pts->setNonInteractive();
  }
}

void FrameTeams::resetColors()
{
  currentColor=availableColors.begin();
}

QColor FrameTeams::getNextColor() const
{
  QList<QColor>::ConstIterator nextColor=currentColor;
  ++nextColor;
  if (nextColor==availableColors.end()) nextColor=availableColors.begin();
  return *nextColor;
}

void FrameTeams::addTeam(HWTeam team, bool willPlay)
{
  TeamShowWidget* pTeamShowWidget = new TeamShowWidget(team, willPlay, this);
  if(nonInteractive) pTeamShowWidget->setNonInteractive();
//  int hght=teamToWidget.empty() ? 0 : teamToWidget.begin()->second->size().height();
  mainLayout.addWidget(pTeamShowWidget);
  teamToWidget.insert(team, pTeamShowWidget);
  QResizeEvent* pevent=new QResizeEvent(parentWidget()->size(), parentWidget()->size());
  QCoreApplication::postEvent(parentWidget(), pevent);
}

void FrameTeams::removeTeam(HWTeam team)
{
  tmapTeamToWidget::iterator it=teamToWidget.find(team);
  if(it==teamToWidget.end()) return;
  mainLayout.removeWidget(it.value());
  it.value()->deleteLater();
  teamToWidget.erase(it);
}

void FrameTeams::resetTeams()
{
  for(tmapTeamToWidget::iterator it=teamToWidget.begin(); it!=teamToWidget.end(); ) {
    mainLayout.removeWidget(it.value());
    it.value()->deleteLater();
    teamToWidget.erase(it++);
  }
}

void FrameTeams::setHHNum(const HWTeam& team)
{
  TeamShowWidget* pTeamShowWidget = dynamic_cast<TeamShowWidget*>(getTeamWidget(team));
  if(!pTeamShowWidget) return;
  pTeamShowWidget->setHHNum(team.numHedgehogs);
}

void FrameTeams::setTeamColor(const HWTeam& team)
{
  TeamShowWidget* pTeamShowWidget = dynamic_cast<TeamShowWidget*>(getTeamWidget(team));
  if(!pTeamShowWidget) return;
  pTeamShowWidget->changeTeamColor(team.teamColor);
}

QWidget* FrameTeams::getTeamWidget(HWTeam team)
{
//qDebug() << "FrameTeams::getTeamWidget getNetID() = " << team.getNetID();
  tmapTeamToWidget::iterator it=teamToWidget.find(team);
  QWidget* ret = it!=teamToWidget.end() ? it.value() : 0;
  return ret;
}

bool FrameTeams::isFullTeams() const
{
  return overallHedgehogs==maxHedgehogsPerGame;
}

void FrameTeams::emitTeamColorChanged(const HWTeam& team)
{
  emit teamColorChanged(team);
}
