/*
 * Hedgewars, a free turn based strategy game
 * Copyright (c) 2007 Igor Ulyanov <iulyanov@gmail.com>
 * Copyright (c) 2007-2011 Andrey Korotaev <unC0Rr@gmail.com>
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

#ifndef _CHAT_WIDGET_INCLUDED
#define _CHAT_WIDGET_INCLUDED

#include <QWidget>
#include <QListWidget>
#include <QString>
#include <QGridLayout>
#include <QRegExp>

#include "SDLInteraction.h"

#include "SmartLineEdit.h"

class ListWidgetNickItem;
class QTextBrowser;
class QLineEdit;
class QListWidget;
class QSettings;

/// This class is for custom nickname sorting
class ListWidgetNickItem : public QListWidgetItem
{
public:
  ListWidgetNickItem(const QString& nick, bool isFriend, bool isIgnored);
  bool operator<(const QListWidgetItem & other) const;
  void setFriend(bool isFriend);
  void setIgnored(bool isIgnored);
  bool isFriend();
  bool ignored();

private:
  bool aFriend;
  bool isIgnored;
};

class HWChatWidget : public QWidget
{
  Q_OBJECT

 public:
  HWChatWidget(QWidget* parent, QSettings * gameSettings, bool notify);
  void loadLists(const QString & nick);
  void saveLists(const QString & nick);
  void setShowReady(bool s);
  void setShowFollow(bool enabled);
  QStringList ignoreList, friendsList;
  static QString & styleSheet();
  void displayError(const QString & message);
  void displayNotice(const QString & message);
  void displayWarning(const QString & message);

private:
  static QString * s_styleSheet;
  static QStringList * s_displayNone;

  void loadList(QStringList & list, const QString & file);
  void saveList(QStringList & list, const QString & file);
  void updateNickItem(QListWidgetItem *item);
  void updateNickItems();
  void addLine(const QString & cssClass, QString line);
  static const QRegExp URLREGEXP;

 public slots:
  void onChatString(const QString& str);
  void onChatString(const QString& nick, const QString& str);
  void onServerMessage(const QString& str);
  void nickAdded(const QString& nick, bool notifyNick);
  void nickRemoved(const QString& nick);
  void clear();
  void setReadyStatus(const QString & nick, bool isReady);
  void adminAccess(bool);

 signals:
  void chatLine(const QString& str);
  void kick(const QString & str);
  void ban(const QString & str);
  void info(const QString & str);
  void follow(const QString &);
  void nickCountUpdate(int cnt);

 private:
  QGridLayout mainLayout;
  QTextBrowser* chatText;
  QStringList chatStrings;
  QListWidget* chatNicks;
  SmartLineEdit* chatEditLine;
  QAction * acInfo;
  QAction * acKick;
  QAction * acBan;
  QAction * acFollow;
  QAction * acIgnore;
  QAction * acFriend;
  QSettings * gameSettings;
  QString helloSound;
  bool notify;
  bool showReady;

 private slots:
  void returnPressed();
  void onBan();
  void onKick();
  void onInfo();
  void onFollow();
  void onIgnore();
  void onFriend();
  void chatNickDoubleClicked(QListWidgetItem * item);
  void chatNickSelected(int index);
  void linkClicked(const QUrl & link);
};

#endif // _CHAT_WIDGET_INCLUDED
