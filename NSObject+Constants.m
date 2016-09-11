//
//  NSObject+Constants.m
//  CalculatorProject
//
//  Created by Edoardo Franco Vianelli on 7/27/16.
//  Copyright © 2016 Edoardo Franco Vianelli. All rights reserved.
//

#import "NSObject+Constants.h"

@implementation NSObject (Constants)

-(BOOL)isInterfaceBuilder{
#if TARGET_INTERFACE_BUILDER
    return true;
#endif
    return false;
}

@end
