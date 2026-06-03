/* === This file is part of Calamares - <https://calamares.io> ===
 *
 *   SPDX-FileCopyrightText: 2026 esterOS contributors
 *   SPDX-License-Identifier: GPL-3.0-or-later
 *
 *   Calamares is Free Software: see the License-Identifier above.
 *
 */

#ifndef PAGETRANSITIONEFFECT_H
#define PAGETRANSITIONEFFECT_H

#include "DllMacro.h"

#include <QGraphicsEffect>

/** @brief Opacity and uniform scale for installer page transitions. */
class UIDLLEXPORT PageTransitionEffect : public QGraphicsEffect
{
    Q_OBJECT
    Q_PROPERTY( qreal opacity READ opacity WRITE setOpacity NOTIFY opacityChanged FINAL )
    Q_PROPERTY( qreal scale READ scale WRITE setScale NOTIFY scaleChanged FINAL )

public:
    explicit PageTransitionEffect( QObject* parent = nullptr );

    qreal opacity() const { return m_opacity; }
    void setOpacity( qreal opacity );

    qreal scale() const { return m_scale; }
    void setScale( qreal scale );

Q_SIGNALS:
    void opacityChanged( qreal opacity );
    void scaleChanged( qreal scale );

protected:
    void draw( QPainter* painter ) override;

private:
    qreal m_opacity = 1.0;
    qreal m_scale = 1.0;
};

#endif  // PAGETRANSITIONEFFECT_H
