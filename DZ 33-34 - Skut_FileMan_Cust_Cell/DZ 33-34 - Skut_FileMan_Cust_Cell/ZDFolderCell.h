//
//  ZDFolderCell.h
//  DZ 33-34 - Skut_FileMan_Cust_Cell
//
//  Created by mac on 11.02.2018.
//  Copyright © 2018 Dima Zgera. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZDFolderCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imgViewCell;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *sizeLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;



@end
