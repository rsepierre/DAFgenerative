package controlP5;

/**
 * controlP5 is a processing gui library.
 * 
 * 2006-2015 by Andreas Schlegel
 * 
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public License
 * as published by the Free Software Foundation; either version 2.1
 * of the License, or (at your option) any later version.
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 * 
 * You should have received a copy of the GNU Lesser General
 * Public License along with this library; if not, write to the
 * Free Software Foundation, Inc., 59 Temple Place, Suite 330,
 * Boston, MA 02111-1307 USA
 * 
 * @author Andreas Schlegel (http://www.sojamo.de)
 * @modified 04/14/2016
 * @version 2.2.6
 * 
 */

import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;

import processing.core.PGraphics;

/**
 * A simple color picker using sliders to adjust RGBA values.
 * 
 * @example controllers/ControlP5colorPicker
 */
public class BetterColorPicker extends ControlGroup< BetterColorPicker > {

	protected Slider sliderRed;

	protected Slider sliderGreen;

	protected Slider sliderBlue;

	protected Canvas currentColor;

	private Object _myPlug;

	private String _myPlugName;

	private boolean broadcast;

	/**
	 * Convenience constructor to extend ColorPicker.
	 * 
	 * @example use/ControlP5extendController
	 * @param theControlP5
	 * @param theName
	 */
	public BetterColorPicker( ControlP5 theControlP5 , String theName ) {
		this( theControlP5 , theControlP5.getDefaultTab( ) , theName , 0 , 0 , 205 , 14 );
		theControlP5.register( theControlP5.papplet , theName , this );
	}

	protected BetterColorPicker( ControlP5 theControlP5 , ControllerGroup< ? > theParent , String theName , int theX , int theY , int theWidth , int theHeight ) {
		super( theControlP5 , theParent , theName , theX , theY , theWidth , theHeight );
		isBarVisible = false;
		isCollapse = false;
		_myArrayValue = new float[] { 255 , 255 , 255 , 255 };

		currentColor = addCanvas( new ColorField( ) );
		sliderRed = cp5.addSlider( theName + "-red" , 0 , 255 , 0 , 0 , theWidth , theHeight );
		cp5.removeProperty( sliderRed );
		sliderRed.setId( 0 );
		sliderRed.setBroadcast( false );
		sliderRed.addListener( this );
		sliderRed.moveTo( this );
		sliderRed.setMoveable( false );
		sliderRed.setColorBackground( 0xff660000 );
		sliderRed.setColorForeground( 0xffaa0000 );
		sliderRed.setColorActive( 0xffff0000 );
		sliderRed.getCaptionLabel( ).setVisible( false );
		sliderRed.setDecimalPrecision( 0 );
		sliderRed.setValue( 255 );

		sliderGreen = cp5.addSlider( theName + "-green" , 0 , 255 , 0 , theHeight + 1 , theWidth , theHeight );
		cp5.removeProperty( sliderGreen );
		sliderGreen.setId( 1 );
		sliderGreen.setBroadcast( false );
		sliderGreen.addListener( this );
		sliderGreen.moveTo( this );
		sliderGreen.setMoveable( false );
		sliderGreen.setColorBackground( 0xff006600 );
		sliderGreen.setColorForeground( 0xff00aa00 );
		sliderGreen.setColorActive( 0xff00ff00 );
		sliderGreen.getCaptionLabel( ).setVisible( false );
		sliderGreen.setDecimalPrecision( 0 );
		sliderGreen.setValue( 255 );

		sliderBlue = cp5.addSlider( theName + "-blue" , 0 , 255 , 0 , ( theHeight + 1 ) * 2 , theWidth , theHeight );
		cp5.removeProperty( sliderBlue );
		sliderBlue.setId( 2 );
		sliderBlue.setBroadcast( false );
		sliderBlue.addListener( this );
		sliderBlue.moveTo( this );
		sliderBlue.setMoveable( false );
		sliderBlue.setColorBackground( 0xff000066 );
		sliderBlue.setColorForeground( 0xff0000aa );
		sliderBlue.setColorActive( 0xff0000ff );
		sliderBlue.getCaptionLabel( ).setVisible( false );
		sliderBlue.setDecimalPrecision( 0 );
		sliderBlue.setValue( 255 );

		_myPlug = cp5.papplet;
		_myPlugName = getName( );
		if ( !ControllerPlug.checkPlug( _myPlug , _myPlugName , new Class[] { int.class } ) ) {
			_myPlug = null;
		}
		broadcast = true;
	}

	public BetterColorPicker plugTo( Object theObject ) {
		_myPlug = theObject;
		if ( !ControllerPlug.checkPlug( _myPlug , _myPlugName , new Class[] { int.class } ) ) {
			_myPlug = null;
		}
		return this;
	}

	public BetterColorPicker plugTo( Object theObject , String thePlugName ) {
		_myPlug = theObject;
		_myPlugName = thePlugName;
		if ( !ControllerPlug.checkPlug( _myPlug , _myPlugName , new Class[] { int.class } ) ) {
			_myPlug = null;
		}
		return this;
	}

	@Override
	@ControlP5.Invisible
	public void controlEvent( ControlEvent theEvent ) {
		if ( broadcast ) {
			_myArrayValue[ theEvent.getId( ) ] = theEvent.getValue( );
			broadcast( );
		}
	}

	private BetterColorPicker broadcast( ) {
		ControlEvent ev = new ControlEvent( this );
		setValue( getColorValue( ) );
		cp5.getControlBroadcaster( ).broadcast( ev , ControlP5Constants.EVENT );
		if ( _myPlug != null ) {
			try {
				Method method = _myPlug.getClass( ).getMethod( _myPlugName , int.class );
				method.invoke( _myPlug , ( int ) getColorValue( ) );
			} catch ( SecurityException ex ) {
				ex.printStackTrace( );
			} catch ( NoSuchMethodException ex ) {
				ex.printStackTrace( );
			} catch ( IllegalArgumentException ex ) {
				ex.printStackTrace( );
			} catch ( IllegalAccessException ex ) {
				ex.printStackTrace( );
			} catch ( InvocationTargetException ex ) {
				ex.printStackTrace( );
			}
		}
		return this;
	}

	/**
	 * Requires an array of size 4 for RGBA
	 * 
	 * @return ColorPicker
	 */
	@Override
	public BetterColorPicker setArrayValue( float[] theArray ) {
		broadcast = false;
		sliderRed.setValue( theArray[ 0 ] );
		sliderGreen.setValue( theArray[ 1 ] );
		sliderBlue.setValue( theArray[ 2 ] );
		broadcast = true;
		_myArrayValue = theArray;
		return broadcast( );
	}

	/**
	 * {@inheritDoc}
	 */
	@Override
	public BetterColorPicker setColorValue( int theColor ) {
		setArrayValue( new float[] { theColor >> 16 & 0xff , theColor >> 8 & 0xff , theColor >> 0 & 0xff , theColor >> 24 & 0xff } );
		return this;
	}

	public int getColorValue( ) {
		return 0xffffffff & ( int ) ( _myArrayValue[ 3 ] ) << 24 | ( int ) ( _myArrayValue[ 0 ] ) << 16 | ( int ) ( _myArrayValue[ 1 ] ) << 8 | ( int ) ( _myArrayValue[ 2 ] ) << 0;
	}

	private class ColorField extends Canvas {

		public void draw( PGraphics theGraphics ) {
			theGraphics.fill( _myArrayValue[ 0 ] , _myArrayValue[ 1 ] , _myArrayValue[ 2 ] , _myArrayValue[ 3 ] );
            theGraphics.stroke(255);
			theGraphics.rect( 213 , 0 , 42 , 42 );
		}
	}

	/**
	 * @exclude {@inheritDoc}
	 */
	@Override
	public String getInfo( ) {
		return "type:\tBetterColorPicker\n" + super.toString( );
	}
}

// some inspiration
// http://www.nbdtech.com/blog/archive/2008/04/27/Calculating-the-Perceived-Brightness-of-a-Color.aspx
// http://alienryderflex.com/hsp.html