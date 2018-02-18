//
//  ZDViewController.m
//  DZ 33-34 - Skut_FileMan_Cust_Cell
//
//  Created by mac on 11.02.2018.
//  Copyright © 2018 Dima Zgera. All rights reserved.
//

#import "ZDViewController.h"
#import "ZDFileCell.h"
#import "ZDFolderCell.h"

@interface ZDViewController ()

@property (weak, nonatomic) IBOutlet UITableView* tableView;
@property (strong, nonatomic) NSFileManager* fileManager;
@property (strong, nonatomic) NSArray* contents;

@end

@implementation ZDViewController

-(instancetype)initWithFolderPath: (NSString*) path {
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    NSString* identifier = @"ZDViewController";
    self = [storyboard instantiateViewControllerWithIdentifier:identifier];
    if (self) {
        self.path = path;
    }
    return self;
}

-(void)loadView {
    [super loadView];
    
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    
    //self.tableView.dataSource = self;
    //self.tableView.delegate = self;
    
}

- (void) dealloc {
    NSLog(@"controller with path %@ has been deallocated", self.path);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (!self.path) {
        
        self.path = @"/Users/mac/Desktop";
        
    }
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    self.navigationItem.title = [self.path lastPathComponent];
    
}
- (void)setPath:(NSString *)path {
    
    _path = path;
    
    self.contents = [[NSArray alloc] init];
    
    self.fileManager = [NSFileManager defaultManager];
    
    NSURL* url = [NSURL fileURLWithPath:self.path];
    self.contents = [NSArray arrayWithArray:[self.fileManager contentsOfDirectoryAtURL:url includingPropertiesForKeys:[NSArray arrayWithObject:NSURLNameKey] options:NSDirectoryEnumerationSkipsHiddenFiles error:nil]];
    
    [self.tableView reloadData];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDelegate

- (BOOL) tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSError* error = nil;
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        NSString* fileName = [self getFileNameAtIndex:indexPath.row];
        [self.fileManager removeItemAtPath:[self.path stringByAppendingPathComponent:fileName] error:&error];
        [self updateContent];
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView endUpdates];
        
    }
    
    if (error) {
        NSLog(@"%@", error.localizedDescription);
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
    if ([self isDirectoryAtIndexPath:indexPath]) {
        
        NSString* fileName = [self getFileNameAtIndex:indexPath.row];
        
        ZDViewController* vc = [[ZDViewController alloc] initWithFolderPath:[self.path stringByAppendingPathComponent:fileName]];
        
        [self.navigationController pushViewController:vc animated:YES];
        
        //vc.path = [self.path stringByAppendingPathComponent:fileName];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [self.contents count];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString* folderIdentifier = @"FolderCell";
    NSString* fileIdentifier = @"FileCell";
    
    NSString* fileName = [self.contents objectAtIndex:indexPath.row];
    
    if ([self isDirectoryAtIndexPath:indexPath]) {
        
        ZDFolderCell* cell = [self.tableView dequeueReusableCellWithIdentifier:folderIdentifier];
        
        cell.imgViewCell.image = [UIImage imageNamed:@"folder.png"];
        cell.nameLabel.text = [self getFileNameAtIndex:indexPath.row];
        cell.sizeLabel.text = [self getSizeOfFileAtIndexPath:indexPath];
        cell.dateLabel.text = [self getModificationDateOfFileAtIndexPath:indexPath];
        
        return cell;
        
    } else {
        
        ZDFileCell* cell = [self.tableView dequeueReusableCellWithIdentifier:fileIdentifier];
        
        cell.imgViewCell.image = [UIImage imageNamed:@"file.png"];
        cell.nameLabel.text = [self getFileNameAtIndex:indexPath.row];
        cell.sizeLabel.text = [self getSizeOfFileAtIndexPath:indexPath];
        cell.dateLabel.text = [self getModificationDateOfFileAtIndexPath:indexPath];
        
        return cell;
        
    }
}

#pragma mark - Actions

- (IBAction)sortButtonAction:(id)sender {
    
    NSMutableArray* tempArray = [[NSMutableArray alloc] init];
    NSMutableArray* foldersArray = [[NSMutableArray alloc] init];
    NSMutableArray* filesArray = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < [self.contents count]; i++) {
        
        NSString* fileName = [self getFileNameAtIndex:i];
        
        if ([self isDirectoryAtPath:[self.path stringByAppendingPathComponent:fileName]]) {
            [foldersArray addObject:fileName];
        } else {
            [filesArray addObject:fileName];
        }
        
    }
    
    [foldersArray sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [obj1 compare:obj2];
    }];
    
    [filesArray sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [obj1 compare:obj2];
    }];
    
    [tempArray addObjectsFromArray:foldersArray];
    [tempArray addObjectsFromArray:filesArray];
    
    self.contents = [NSArray arrayWithArray:tempArray];
    
    NSIndexSet* indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [self.tableView numberOfSections])];
    
    [self.tableView beginUpdates];
    [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView endUpdates];
    
}

- (IBAction)addButtonAction:(id)sender {
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Enter name for new directory" message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Enter name";
    }];
    
    UIAlertAction* done = [UIAlertAction actionWithTitle:@"Done" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        UITextField* nameField = alert.textFields[0];
        
        NSString* newDirectoryName = nameField.text;
        
        NSError* error = nil;
        
        /*   NSDictionary* attributes = [NSDictionary dictionaryWithObjectsAndKeys:<#(nonnull id), ...#>, nil]*/
        
        [self.fileManager createDirectoryAtPath:[self.path stringByAppendingPathComponent:newDirectoryName] withIntermediateDirectories:NO attributes:nil error:&error];
        
        if (error) {
            NSLog(@"%@", error);
        } else {
            [self updateContent];
            NSInteger index = [self.contents indexOfObject:[NSURL fileURLWithPath:[self.path stringByAppendingPathComponent:newDirectoryName]]];
            NSIndexPath* indexPath = [NSIndexPath indexPathForRow:index inSection:0];
            NSLog(@"%ld", (long)index);
            [self insertRowAtIndexPath:indexPath];
            [self updateContent];
        }
        
    }];
    
    [alert addAction:cancel];
    [alert addAction:done];
    
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Other

-(NSString*)getFileNameAtIndex:(int) index {
    NSURL* fileURL = [self.contents objectAtIndex:index];
    
    return fileURL.lastPathComponent;
}

- (void)insertRowAtIndexPath:(NSIndexPath*) indexPath {
    NSArray* visibleCells = [self.tableView visibleCells];
    
    BOOL isVisible = NO;
    
    for (UITableViewCell* cell in visibleCells) {
        
        NSIndexPath* indexPathOfVisibleCell = [self.tableView indexPathForCell:cell];
        
        if ([indexPath isEqual:indexPathOfVisibleCell ]) {
            isVisible = YES;
            break;
        }
        
    }
    
    [self.tableView beginUpdates];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView endUpdates];
    
    if (!isVisible) {
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    }
    
}

- (BOOL)isDirectoryAtIndexPath:(NSIndexPath *) indexPath {
    
    NSString* fileName = [self getFileNameAtIndex:indexPath.row];
    
    NSString* filePath = [self.path stringByAppendingPathComponent:fileName];
    
    return [self isDirectoryAtPath:filePath];
}

- (BOOL)isDirectoryAtPath:(NSString*)path {
    
    BOOL isDirectory = NO;
    
    [self.fileManager fileExistsAtPath:path isDirectory:&isDirectory];
    
    return isDirectory;
}

- (NSString*)getModificationDateOfFileAtIndexPath:(NSIndexPath*) indexPath {
    
    NSString* modificationDateString;
    
    NSString* fileName = [self getFileNameAtIndex:indexPath.row];
    
    NSDictionary* attributes = [self.fileManager attributesOfItemAtPath:[self.path stringByAppendingPathComponent:fileName] error:nil];
    
    static NSDateFormatter* dateFormatter = nil;
    
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"dd.MMMM.YYYY, hh:mm:ss"];
    }
    
    NSDate* modificationDate = [attributes objectForKey:NSFileModificationDate];
    
    modificationDateString = [dateFormatter stringFromDate:modificationDate];
    
    return modificationDateString;
    
}

-(NSString*)getSizeOfFileAtIndexPath:(NSIndexPath*) indexPath {
    
    NSString* sizeString = [[NSString alloc] init];
    
    static NSString* units[] = {@"B", @"kb", @"MB", @"GB", @"TB"};
    static int count = 5;
    
    int index = 0;
    
    NSString* fileName = [self getFileNameAtIndex:indexPath.row];
    
    NSDictionary* attributes = [self.fileManager attributesOfItemAtPath:[self.path stringByAppendingPathComponent:fileName] error:nil];
    
    double fileSize = [attributes fileSize];
    
    while (fileSize > 1024 && index < count) {
        fileSize /= 1024;
        index++;
    }
    
    sizeString = [NSString stringWithFormat:@"%.2f %@", fileSize,units[index]];
    
    return sizeString;
}

- (NSString*)getSizeOfFolderAtIndexPath:(NSIndexPath*) indexPath {
    
    NSString* path = [self.contents objectAtIndex:indexPath.row];
    
    NSArray *filesArray = [self.fileManager subpathsOfDirectoryAtPath:path error:nil];
    NSEnumerator *filesEnumerator = [filesArray objectEnumerator];
    NSString *fileName;
    unsigned long long int fileSize = 0;
    
    while (fileName = [filesEnumerator nextObject]) {
        
        NSDictionary *fileDictionary = [[NSFileManager defaultManager] fileAttributesAtPath:[path stringByAppendingPathComponent:fileName] traverseLink:YES];
        
        fileSize += [fileDictionary fileSize];
    }
    
    NSString* sizeString = [[NSString alloc] init];
    
    static NSString* units[] = {@"B", @"kb", @"MB", @"GB", @"TB"};
    static int count = 5;
    
    int index = 0;
    
    while (fileSize > 1024 && index < count) {
        fileSize /= 1024;
        index++;
    }
    
    sizeString = [NSString stringWithFormat:@"%.2llu %@", fileSize,units[index]];
    
    return sizeString;
}

- (void) updateContent {
    
    NSURL* url = [NSURL fileURLWithPath:self.path];
    self.contents = [NSArray arrayWithArray:[self.fileManager contentsOfDirectoryAtURL:url includingPropertiesForKeys:[NSArray arrayWithObject:NSURLNameKey] options:NSDirectoryEnumerationSkipsHiddenFiles error:nil]];
}






@end
