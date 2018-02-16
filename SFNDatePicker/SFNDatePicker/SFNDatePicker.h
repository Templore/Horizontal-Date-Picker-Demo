
/**
 *  SFNDatePicker.h
 *  Created by Siksfonine on 2015.02.10
 */

#import <UIKit/UIKit.h>

@interface SFNDatePicker : UIView

- (instancetype)initWithFrame:(CGRect)frame;

/* When the 'date' is nil, 'dayInterval' will be used, otherwise it will be ignored */
- (NSDateComponents *)getDateComponentsFromDate:(NSDate *)date
                                  orDayInterval:(NSInteger)dayInterval;

/* When the 'date' is nil, 'dayInterval' will be used, otherwise it will be ignored */
- (NSString *)getDateStringByDate:(NSDate *)date orDayInterval:(NSInteger)dayInterval;

/* Return today */
- (NSString *)getCurrentYear;
- (NSString *)getCurrentMonth;
- (NSString *)getCurrentday;
- (NSString *)getCurrentWeekday;
- (NSString *)getToday;

/* d */

@end