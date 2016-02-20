//
//  Constants.h
//  ThePorter
//
//  Created by Pankaj Jha on 20/02/16.
//  Copyright © 2016 Pankaj Jha. All rights reserved.
//

#ifndef Constants_h
#define Constants_h

#define PER_PAGE_COUNT   20
#define OOPS_ERROR    @"Oops! Something went wrong. Please Retry"
#define APPLICATION_NAME  @"The Porter"
#define OK_MESSAGE @"OK"
#define DATA_LIMIT 3

typedef enum sort
{
    SortTypeName = 0,
    SortTypeValue,
    SortTypeWeight
} SortType;

typedef enum order
{
    OrderByASC = 0,
    OrderByDESC
} OrderBy;

#define UIColorFromRGB(rgbValue) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0x00FF00) >>  8))/255.0 \
blue:((float)((rgbValue & 0x0000FF) >>  0))/255.0 \
alpha:1.0]

#endif /* Constants_h */
