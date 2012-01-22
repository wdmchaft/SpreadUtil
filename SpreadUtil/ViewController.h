/*
 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by 
 the Free Software Foundation, either version 3 of the License, or any later version.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  
 See the GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License 
 along with this program.  If not, see <http://www.gnu.org/licenses/>. 
 
 Created by Takuya Chaen on 2012/01/18.
 Copyright (c) 2012年 Offlab All rights reserved.
 */
//  ViewController.h
//  SpreadUtil


#import <UIKit/UIKit.h>
#import "GData.h"

#define OPEN_SETTING 1
#define FEED_INIT 1
#define GETTING_WORKSHEET 1
#define LIST_GET 1
#define EDIT_VIEW 1

@interface ViewController : UIViewController<UIActionSheetDelegate,UIAlertViewDelegate,UITableViewDelegate
,UITableViewDataSource,UIPickerViewDelegate,UIPickerViewDataSource> {
    GDataServiceGoogleSpreadsheet *SpreadSheetService;
    GDataFeedSpreadsheet *SpreadsheetFeedEntry;
    UIView *LoadingView;
    UINavigationBar *navigationBar;
    NSMutableArray *UserInfo;
    NSMutableArray *AllArray;
    UIActivityIndicatorView *LoadingIndicator;
    UITextView *TextEditView;
    UIAlertView *SettigView;
    NSInteger OpenSettingFlag;
    UIButton *SaveSettingBt;
    UIButton *CloseSettingBt;
    UITextField *UserField;
    UITextField *PassField;
    UILabel *UserLabel;
    UILabel *PassLabel;
    UITableView *TableView;
    UIImage *SpreadImage;
    NSInteger GetWorksheetFlag;
    NSInteger FeedGetFlag;
    UIAlertView *InputView;
    NSInteger ListGettedflag;
    UIPickerView *WorkSheetPicker;
    UIAlertView *WorkSheetView;
    NSInteger CurrentDatIndex;
    UIToolbar *Toolbar;
    NSInteger WorkSheetIndexForAdd;
    UIAlertView *EditTextView;
    NSInteger EditFlag;
    NSInteger CurrentChangeIndex;
    NSInteger CurrentWorkSheetIndex;
    NSMutableArray *InternalShowBuffer;
    NSMutableArray *InternalListArr;
    NSMutableArray *InternalListFeedArr;
    NSMutableArray *InternalWorksheetTitle;
    NSMutableArray *InternalWorkSheetArr;
    NSMutableArray *InternalSpreadSheetEntryArr;
    NSMutableArray *InternalSpreadSheetTitleArr;
}

@property (nonatomic, retain) GDataServiceGoogleSpreadsheet *SpreadSheetService;
@property (nonatomic, retain) GDataFeedSpreadsheet *SpreadsheetFeedEntry;
@property (nonatomic, retain) UIView *LoadingView;
@property (nonatomic, retain) UINavigationBar *navigationBar;
@property (nonatomic, retain) NSMutableArray *UserInfo;
@property (nonatomic, retain) NSMutableArray *AllArray;
@property (nonatomic, retain) UIActivityIndicatorView *LoadingIndicator;
@property (nonatomic, retain) UITextView *TextEditView;
@property (nonatomic, retain) UIAlertView *SettigView;
@property (nonatomic, retain) UIButton *SaveSettingBt;
@property (nonatomic, retain) UIButton *CloseSettingBt;
@property (nonatomic, retain) UITextField *UserField;
@property (nonatomic, retain) UITextField *PassField;
@property (nonatomic, retain) UILabel *UserLabel;
@property (nonatomic, retain) UILabel *PassLabel;
@property (nonatomic, retain) UITableView *TableView;
@property (nonatomic, retain) UIImage *SpreadImage;
@property (nonatomic, retain) UIAlertView *InputView;
@property (nonatomic, retain) UIPickerView *WorkSheetPicker;
@property (nonatomic, retain) UIAlertView *WorkSheetView;
@property (nonatomic, retain) UIToolbar *Toolbar;
@property (nonatomic, retain) UIAlertView *EditTextView;
@property (nonatomic, retain) NSMutableArray *InternalShowBuffer;
@property (nonatomic, retain) NSMutableArray *InternalListArr;
@property (nonatomic, retain) NSMutableArray *InternalListFeedArr;
@property (nonatomic, retain) NSMutableArray *InternalWorksheetTitle;
@property (nonatomic, retain) NSMutableArray *InternalWorkSheetArr;
@property (nonatomic, retain) NSMutableArray *InternalSpreadSheetEntryArr;
@property (nonatomic, retain) NSMutableArray *InternalSpreadSheetTitleArr;

-(void)RemoveAllDat;
-(void)HomeRefresh;
-(NSMutableArray *)GetElementList;
-(void)SaveDat;
-(void)RefreshDatListView:(NSInteger )TableViewIndex:(NSString *)ChangeDat;
-(void)OpenEdit:(NSInteger )Index;
-(void)CloseEdit;
-(void)NextDat;
-(void)BackDat;
-(void)CloseSetting;
-(void)SaveUserInfo;
-(void)SaveInfo;
-(void)GetUserInfo;
-(void)OpenSetting;
-(void)InitSettingView;
-(void)Init_Array;
-(void)LoadView;
-(void)Init_Array;
-(void)GetWorkSheetList:(GDataEntryWorksheet *)WorkSheet;
-(void)InitWorksheetView;
-(void)Initial_GetSpreadSheetFeed;
-(void)SetShowbuffer;
-(void)CloseWorksheetView;
-(void)ShowWorkSheetView;
-(void)GetWorkSheetFeedWithIndex:(NSInteger)clickindex;
-(void)setupSpreadSheetService:(NSString*)username password:(NSString*)password;
-(GDataServiceGoogleSpreadsheet *)GetSpreadSheetService:(NSString*)username password:(NSString*)password ;
-(void)HandleSpreadSheetFeedInitial;
-(void)InitImages;
-(void)ShowNetworkAlert;
-(void)InitWorksheetView;
-(void)GetSpreadSheetFeed:(NSString *)UserName 
                 password:(NSString *)Password;
-(void)Initial_GetSpreadSheetFeed;



@end
