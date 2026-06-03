/* === This file is part of Calamares - <https://calamares.io> ===
 *
 *   SPDX-FileCopyrightText: 2026 esterOS contributors
 *   SPDX-License-Identifier: GPL-3.0-or-later
 *
 *   Calamares is Free Software: see the License-Identifier above.
 *
 */

#include "PageTransitionEffect.h"

#include <QPainter>

PageTransitionEffect::PageTransitionEffect( QObject* parent )
    : QGraphicsEffect( parent )
{
}

void
PageTransitionEffect::setOpacity( qreal opacity )
{
    if ( qFuzzyCompare( m_opacity, opacity ) )
    {
        return;
    }
    m_opacity = opacity;
    update();
    emit opacityChanged( m_opacity );
}

void
PageTransitionEffect::setScale( qreal scale )
{
    if ( qFuzzyCompare( m_scale, scale ) )
    {
        return;
    }
    m_scale = scale;
    update();
    emit scaleChanged( m_scale );
}

void
PageTransitionEffect::draw( QPainter* painter )
{
    if ( !sourceIsPixmap() && !source().isNull() )
    {
        const QRectF bounds = sourceBoundingRect( Qt::LogicalCoordinates );
        const QPointF center = bounds.center();

        painter->setOpacity( m_opacity );
        painter->translate( center );
        painter->scale( m_scale, m_scale );
        painter->translate( -center );
        drawSource( painter );
        return;
    }

    drawSource( painter );
}
