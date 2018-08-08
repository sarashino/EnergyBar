/**
 * @file DockWidget.m
 *
 * @copyright 2018 Bill Zissimopoulos
 */
/*
 * This file is part of TouchBarDock.
 *
 * You can redistribute it and/or modify it under the terms of the GNU
 * General Public License version 3 as published by the Free Software
 * Foundation.
 */

#import "DockWidget.h"

@interface DockWidget_Application : NSObject
@property (retain) NSString *name;
@property (retain) NSString *path;
@property (retain) NSImage *icon;
@end

@implementation DockWidget_Application
@end

@interface DockWidget () <NSScrubberDataSource, NSScrubberFlowLayoutDelegate>
@property (retain) NSArray *defaultApps;
@property (retain) NSArray *runningApps;
@end

static NSString *dockItemIdentifier = @"dockItem";
static NSString *dockSeparatorIdentifier = @"dockSeparator";

@implementation DockWidget
- (void)commonInit
{
    self.customizationLabel = @"Dock";

    NSScrubberFlowLayout *layout = [[[NSScrubberFlowLayout alloc] init] autorelease];
    layout.itemSize = NSMakeSize(50, 30);

    NSScrubber *scrubber = [[[NSScrubber alloc] initWithFrame:NSMakeRect(0, 0, 200, 30)] autorelease];
    [scrubber registerClass:[NSScrubberImageItemView class] forItemIdentifier:dockItemIdentifier];
    [scrubber registerClass:[NSScrubberImageItemView class] forItemIdentifier:dockSeparatorIdentifier];
    scrubber.dataSource = self;
    scrubber.delegate = self;
    scrubber.mode = NSScrubberModeFixed;
    scrubber.continuous = NO;
    scrubber.itemAlignment = NSScrubberAlignmentNone;
    scrubber.scrubberLayout = layout;

    self.view = scrubber;
}

- (void)dealloc
{
    self.defaultApps = nil;
    self.runningApps = nil;
    [super dealloc];
}

- (NSInteger)numberOfItemsForScrubber:(NSScrubber *)scrubber
{
    return self.apps.count;
}

- (NSScrubberItemView *)scrubber:(NSScrubber *)scrubber viewForItemAtIndex:(NSInteger)index
{
    NSScrubberImageItemView *view = [scrubber makeItemWithIdentifier:dockItemIdentifier owner:nil];
    view.image = [[self.apps objectAtIndex:index] icon];
    return view;
}

- (NSArray *)apps
{
    if (nil == self.defaultApps)
    {
        NSArray *defaultApps = [[NSUserDefaults standardUserDefaults] arrayForKey:@"defaultApps"];
        NSMutableArray *newDefaultApps = [NSMutableArray array];
        for (NSDictionary *a in defaultApps)
        {
            DockWidget_Application *app = [[[DockWidget_Application alloc] init] autorelease];
            app.name = [a objectForKey:@"NSApplicationName"];
            app.path = [a objectForKey:@"NSApplicationPath"];
            app.icon = [[NSWorkspace sharedWorkspace] iconForFile:app.path];
            [newDefaultApps addObject:app];
        }
        self.defaultApps = [newDefaultApps copy];
    }

    if (nil == self.runningApps)
    {
        NSArray *runningApps = [[NSWorkspace sharedWorkspace] runningApplications];
        NSMutableArray *newRunningApps = [NSMutableArray array];
        for (NSRunningApplication *a in runningApps)
        {
            if (NSApplicationActivationPolicyRegular != a.activationPolicy)
                continue;
            DockWidget_Application *app = [[[DockWidget_Application alloc] init] autorelease];
            app.name = a.localizedName;
            app.path = a.bundleURL.path;
            app.icon = a.icon;
            [newRunningApps addObject:app];
        }
        self.runningApps = [newRunningApps copy];
    }

    return [self.defaultApps arrayByAddingObjectsFromArray:self.runningApps];
}
@end
