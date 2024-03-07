//
//  SeafSyncAlbumSelectorViewController.m
//  Seafile
//
//  Created by Javier Godoy (javigodoy@meytel.net) on 6/10/23.
//

#import "SeafSyncAlbumSelectorViewController.h"

@interface SeafSyncAlbumSelectorViewController ()
@property (nonatomic, strong) PHFetchResult *albums;
@property (nonatomic, strong) IBOutlet UICollectionView *collectionView;

@property (nonatomic, strong) id<SeafSyncAlbumSelectorViewControllerDelegate> delegate;
@end


@implementation SeafSyncAlbumSelectorViewController

-(id) initWithDelegate:(id<SeafSyncAlbumSelectorViewControllerDelegate>) delegate{
    self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil];
    if(self){
        self.delegate = delegate;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configureLayout];
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"Cell"];
    [self loadAlbums];
    self.title = NSLocalizedString(@"Select Album", @"Seafile");
    
    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
}

-(void) configureLayout{
    //Configure layout
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(self.collectionView.frame.size.width /2.2, self.collectionView.frame.size.width /2.2);

    [self.collectionView setCollectionViewLayout:layout];
}

- (void)loadAlbums {
    
    self.albums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAny options:nil];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.collectionView reloadData];
    });
}



-(UIImage *) getFirstPhotoFromAlbum:(PHAssetCollection *) album{

    __block UIImage *image = nil;
    
    PHFetchResult *assets = [PHAsset fetchAssetsInAssetCollection:album options:nil];

    if (assets.count > 0) {
        
        PHAsset *firstAsset = [assets firstObject];
        
        PHImageManager *manager = [PHImageManager defaultManager];
        PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
        options.synchronous = YES;
        
        [manager requestImageForAsset:firstAsset
                           targetSize:PHImageManagerMaximumSize
                          contentMode:PHImageContentModeDefault
                              options:options
                        resultHandler:^(UIImage *result, NSDictionary *info) {
            if (result) {
                image = result;
            }
        }];
    }
    
    return image;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.albums.count;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];

    //Clean
    [cell.contentView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull subview, NSUInteger idx, BOOL * _Nonnull stop) {
        [subview removeFromSuperview];
    }];
    
    
    PHAssetCollection *album = self.albums[indexPath.item];
    cell.contentView.backgroundColor = [UIColor lightGrayColor];

    //Render first image
    UIImage *fistImage = [self getFirstPhotoFromAlbum:album];
    if(fistImage){
        UIImageView *image = [[UIImageView alloc] initWithFrame:cell.contentView.bounds];
        [image setContentMode:UIViewContentModeScaleAspectFill];
        [image setClipsToBounds:TRUE];
        [image setImage: fistImage];
        [cell.contentView addSubview:image];
    }
    
    //Render album title
    UILabel *label = [[UILabel alloc] initWithFrame:cell.contentView.bounds];
    label.text = album.localizedTitle;
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = UIColor.whiteColor;
    label.font = [UIFont systemFontOfSize:16 weight:0.5];
    [label setBackgroundColor: [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5]];
    [cell.contentView addSubview:label];

    return cell;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0;
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    PHAssetCollection *selectedAlbum = self.albums[indexPath.item];


    if(self.delegate){
        [self.delegate onSelectAlbum:selectedAlbum];
    }
    
    [self dismissViewControllerAnimated:TRUE completion:nil];
}


- (void)photoLibraryDidChange:(PHChange *)changeInstance {
    [self loadAlbums];
}

@end
