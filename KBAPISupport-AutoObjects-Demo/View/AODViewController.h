//
//  AODViewController.h
//  KBAPISupport-AutoObjects-Demo
//
//  Created by Kirill byss Bystrov on 06.12.12.
//  Copyright (c) 2012 Kirill byss Bystrov. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import <UIKit/UIKit.h>

@interface AODViewController : UIViewController <KBAPIConnectionDelegate>

@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *activityView;

@property (retain, nonatomic) IBOutlet UILabel *field1Status;
@property (retain, nonatomic) IBOutlet UILabel *field2Status;
@property (retain, nonatomic) IBOutlet UILabel *field3Status;
@property (retain, nonatomic) IBOutlet UILabel *field4Status;
@property (retain, nonatomic) IBOutlet UILabel *field5Status;

@property (retain, nonatomic) IBOutlet UILabel *field4ObjFieldStatus;

@property (retain, nonatomic) IBOutlet UILabel *field5Obj0Status;
@property (retain, nonatomic) IBOutlet UILabel *field5Obj1Status;
@property (retain, nonatomic) IBOutlet UILabel *field5Obj2Status;

@property (retain, nonatomic) IBOutlet UILabel *field5Obj0FieldStatus;
@property (retain, nonatomic) IBOutlet UILabel *field5Obj1FieldStatus;
@property (retain, nonatomic) IBOutlet UILabel *field5Obj2FieldStatus;

- (IBAction)loadObject:(id)sender;

@end
