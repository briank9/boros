/*=========================================================================
 This file is part of the Horos Project (www.horosproject.org)
 
 Horos is free software: you can redistribute it and/or modify
 it under the terms of the GNU Lesser General Public License as published by
 the Free Software Foundation,  version 3 of the License.
 
 The Horos Project was based originally upon the OsiriX Project which at the time of
 the code fork was licensed as a LGPL project.  However, not all of the the source-code
 was properly documented and file headers were not all updated with the appropriate
 license terms. The Horos Project, originally was licensed under the  GNU GPL license.
 However, contributors to the software since that time have agreed to modify the license
 to the GNU LGPL in order to be conform to the changes previously made to the
 OsiriX Project.
 
 Horos is distributed in the hope that it will be useful, but
 WITHOUT ANY WARRANTY EXPRESS OR IMPLIED, INCLUDING ANY WARRANTY OF
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE OR USE.  See the
 GNU Lesser General Public License for more details.
 
 You should have received a copy of the GNU Lesser General Public License
 along with Horos.  If not, see http://www.gnu.org/licenses/lgpl.html
 
 Prior versions of this file were published by the OsiriX team pursuant to
 the below notice and licensing protocol.
 ============================================================================
 Program:   OsiriX
  Copyright (c) OsiriX Team
  All rights reserved.
  Distributed under GNU - LGPL
  
  See http://www.osirix-viewer.com/copyright.html for details.
     This software is distributed WITHOUT ANY WARRANTY; without even
     the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
     PURPOSE.
 ============================================================================*/

#import "OsiriXToolbar.h"
#import "ViewerController.h"
#import "ToolbarPanel.h"
#import "NSWindow+N2.h"
#import <objc/runtime.h>

@implementation OsiriXToolbar

- (void)runCustomizationPalette:(id)sender
{
	[super runCustomizationPalette: sender];
}

@end

#pragma mark - Toolbar image sizing

// Horos toolbar images are mostly .icns/.tiff files with large representations (up to 1024px).
// Apps linked against SDKs before macOS 26 got these scaled down to the standard 32pt toolbar
// size by AppKit; with the macOS 26+ SDK the toolbar uses the image's own size instead, which
// makes the icons enormous. Constrain every toolbar item image to 32x32pt here, in one place,
// so it applies to all toolbars (browser, viewers, 3D windows and plugins).

static const CGFloat N2ToolbarItemImageMaxSize = 32;

static IMP N2ToolbarItemOriginalSetImage = NULL;

static void N2ToolbarItemSetImage(id self, SEL _cmd, NSImage *image)
{
    if (image && (image.size.width > N2ToolbarItemImageMaxSize || image.size.height > N2ToolbarItemImageMaxSize))
    {
        NSSize size = image.size;
        CGFloat scale = N2ToolbarItemImageMaxSize / MAX(size.width, size.height);
        image = [[image copy] autorelease]; // don't resize shared [NSImage imageNamed:] instances
        image.size = NSMakeSize(round(size.width * scale), round(size.height * scale));
    }
    
    ((void (*)(id, SEL, NSImage *))N2ToolbarItemOriginalSetImage)(self, _cmd, image);
}

@implementation NSToolbarItem (N2ImageSize)

+ (void)load
{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        Method m = class_getInstanceMethod([NSToolbarItem class], @selector(setImage:));
        N2ToolbarItemOriginalSetImage = method_setImplementation(m, (IMP)N2ToolbarItemSetImage);
    });
}

@end
