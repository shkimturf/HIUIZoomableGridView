# HIUIZoomableGridView

General grid view which supports zooming. You can statisfied a user who want to adjust grid cell size.

## Screenshot

![alt tag](https://github.com/shkimturf/HIUIZoomableGridView/blob/master/preview.gif?raw=true)

## Environments

over iOS 7.0

## Usage

### Setup

Just import HIUIZoomableGridView source files to your project.

### Sample 

**HIUIZoomableGridViewSample** project shows how to use this library.

### Layout Manager

* Set zoomLevels to support zooming levels.
* Cell means the rect which contains tile to show. Should return cell size for each zoomlevels
* Tile is actually grid view to show. 
* ContentInset means scrollview content insets. It will be show like below.
** | contentInset | cell | cell | ... | cell | contentInset |

``` objc
    NSInteger minimumZoomLevel;
    NSInteger maximumZoomLevel;

    - (CGSize)cellSizeWithZoomLevel:(NSInteger)zoomLevel;
    - (CGSize)tileSizeWithZoomLevel:(NSInteger)zoomLevel;
```

### DataSource

It likes **UITableViewDataSource**.
* Tile should conform HIUIGridTile protocol. 

``` objc
    - (NSUInteger)numberOfItemsInGridView:(HIUIZoomableGridView*)gridView;
    - (UIView<HIUIGridTile>*)gridView:(HIUIZoomableGridView*)gridView tileAtIndexPath:(NSIndexPath*)indexPath;
```

### Delegate

Supports some kinds of delegate functions.

``` objc
    - (NSInteger)defaultZoomLevelInGridView:(HIUIZoomableGridView*)gridView;
    - (void)gridView:(HIUIZoomableGridView*)gridView willSelectItemAtIndexPath:(NSIndexPath*)indexPath;
    - (void)gridView:(HIUIZoomableGridView*)gridView didSelectItemAtIndexPath:(NSIndexPath*)indexPath;

    - (void)gridView:(HIUIZoomableGridView*)gridView didScroll:(UIScrollView*)scrollView;
    - (void)gridView:(HIUIZoomableGridView*)gridView willBeginDragging:(UIScrollView*)scrollView;
    - (void)gridView:(HIUIZoomableGridView*)gridView willEndDragging:(UIScrollView*)scrollView targetContentOffset:(CGPoint)targetContentOffset;

    - (void)gridView:(HIUIZoomableGridView*)gridView didChangeZoomLevel:(NSInteger)zoomLevel;
    - (void)gridView:(HIUIZoomableGridView*)gridView willShowTile:(UIView<HIUIGridTile>*)tile atIndexPath:(NSIndexPath*)indexPath;
```

## Sample source

**HIUIZoomableGridViewSample** implements explained above.

## Author

[shkimturf](https://github.com/shkimturf)

## License

Tornado+MongoDB-WAS is under MIT License.