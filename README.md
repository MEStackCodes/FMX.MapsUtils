# FMX.MapsUtils

It is a unit for Delphi with several complex conversion functions for working with maps and that can be used in conjunction with the TMapView Maps component.

## Description

```pascal
function GooglePolylineToCoord(const Str: String; Precision: Integer): TArray<TMapCoordinate>;
```
It decodes a Google polyline and converts it to an array of type TMapCoordinate that can be directly manipulated by TMapView to draw a route. The precision value contains the number of decimal places in the coordinate values, the common value is 5.

##

```pascal
function GetCenterCoord(MapCoordinates: TArray<TMapCoordinate>): TMapCoordinate;
```
 Calculates and returns the center of a route, useful for pointing the camera to the center of a polyline.
##

```pascal
function CoordinatesToFitZoom(LatitudeA, LongitudeA, LatitudeB, LongitudeB: Double): Double;
```
Returns the corresponding Zoom value to adjust the display of 2 distant points on the map, the value can be passed directly to the 
TMapView component.

##

```pascal
function HaversineDistance(LatitudeA, LongitudeA, LatitudeB, LongitudeB: Double): Double;
```
Calculates the angular distance between two points on the Earth's surface. It is calculated from the longitude and latitude coordinates of each point. The result value is in meters.


## Share
If you liked and found this repository useful for your projects, star it. Thank you for your support! ⭐