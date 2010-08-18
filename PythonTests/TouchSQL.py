#!/usr/bin/python

import objc

name = 'TouchSQL'
path = '/Users/schwa/Library/Frameworks/TouchSQL.framework'
identifier = 'com.touchcode.TouchSQL'

d = dict()

x = objc.initFrameworkWrapper(frameworkName = name, frameworkPath = path, frameworkIdentifier = identifier, globals = globals())
