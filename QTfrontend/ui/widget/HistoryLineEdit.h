/*
 * Hedgewars, a free turn based strategy game
 * Copyright (c) 2006-2007 Igor Ulyanov <iulyanov@gmail.com>
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

/**
 * @file  HistoryLineEdit.h
 * @brief HistoryLineEdit class definition
 */

#ifndef HEDGEWARS_HISTORYLINEEDIT
#define HEDGEWARS_HISTORYLINEEDIT

#include <QLineEdit>
#include <QString>

#include <QKeyEvent>

#include <QMutex>

class QLineEdit;

/**
 * @brief A <code>QLineEdit</code> that features a history of previous contents,
 *        re-selectable using the arrow keys.
 *
 * Note: Public methods for accessing history are <b>thread-safe</b>.
 * 
 * @author sheepluva
 * @since 0.9.17
 */
class HistoryLineEdit : public QLineEdit
{
 Q_OBJECT

public:
    /**
    * @brief Class constructor.
    * @param parent parent QWidget.
    * @param maxHistorySize maximum amount of history entries kept.
    */
    HistoryLineEdit(QWidget * parent = 0, int maxHistorySize = 64);

    /**
     * @brief Appends current text to history (if not only whitespaces);
     */
    void rememberCurrentText();

    /**
     * @brief Forget all history.
     */
    void reset();


public slots:
    /**
     * @brief Clears the contents.
     */
    void clear();


protected:
    /**
     * @brief Overrides method of parent class.
     * Arrow keys are used for navigating the history.
     *
     * All other keys are forwarded to the parent's method.
     * 
     * @param event the key event.
     */
    virtual void keyPressEvent(QKeyEvent * event);


private:
    int m_maxHistorySize; ///< the maximum allowed size for the history
    int m_curHistEntryIdx; ///< the index of the displayed used entry

    QStringList * m_history; ///< history of previous inputs

    QMutex m_historyMutex; ///< make history QStringList action thread-safe

    /**
     * @brief Navigates content history in the desired direction.
     *
     * Note: no wrap-around on purpose (so that holding down/up will get the
     * the user to the respective end rather than into an endless cycle :P)
     * 
     * @param isGoingUp true: next older entry, false: next more recent entry.
     */
    void navigateHistory(bool isGoingUp);

    /**
     * @brief Appends current text to history, without Mutex.
     */
    void rememberCurrentTextUnsynced();
};



#endif // HEDGEWARS_HISTORYLINEEDIT
