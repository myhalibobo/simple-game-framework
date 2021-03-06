##################################################################################
#                            This file is part of                                #
#                                GodotExplorer                                   #
#                       https://github.com/GodotExplorer                         #
##################################################################################
# Copyright (c) 2019 Godot Explorer                                              #
#                                                                                #
# Permission is hereby granted, free of charge, to any person obtaining a copy   #
# of this software and associated documentation files (the "Software"), to deal  #
# in the Software without restriction, including without limitation the rights   #
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell      #
# copies of the Software, and to permit persons to whom the Software is          #
# furnished to do so, subject to the following conditions:                       #
#                                                                                #
# The above copyright notice and this permission notice shall be included in all #
# copies or substantial portions of the Software.                                #
#                                                                                #
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR     #
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,       #
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE    #
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER         #
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,  #
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE  #
# SOFTWARE.                                                                      #
##################################################################################

# @class `EventEmitter`
# 基础事件管理器

tool
extends Reference
class_name EventEmitter

# 回调对象
class EventHandler extends Handler:
	var type: String = ""
	var one_shot = false

# 事件回调表
# Map<String, EventHandler[]>
var _event_handlers = {}

# 派发事件  
# - - - - - - - - - -  
# *Parameters*  
# * [type: String] 事件类型  
# * [params: Variant = null] 事件参数  
#
func emit(type: String, params = []):
	if type in _event_handlers:
		var remove_handlers = []
		var handlers = _event_handlers[type]
		for handler in handlers:
			handler.call_func(params)
			if handler.one_shot:
				remove_handlers.append(handler)
		for rh in remove_handlers:
			handlers.erase(rh)

# 添加事件侦听  
# - - - - - - - - - -  
# *Parameters*  
# * [type:String] 事件类型  
# * [target:Object] 回调对象  
# * [method: String] 回调方法  
# * [arguments: Array] 绑定的参数，会展开并传递到回调方法的末尾参数
# 
# 注意: 参数中的引用类型会增加引用计数，请使用弱引用传递值避免循环引用
# - - - - - - - - - -  
# *Returns* EventHandler  
# * 返回事件回调对象，可用于取消回调
func on(type: String, target: Object, method: String, arguments = []) -> EventHandler:
	var handler = EventHandler.new()
	handler.type = type
	handler.target = target
	handler.method = method
	handler.one_shot = false
	handler.arguments = arguments
	if type in _event_handlers:
		_event_handlers[type].append(handler)
	else:
		_event_handlers[type] = [handler]
	return handler

# 添加只执行一次的回调事件  
# - - - - - - - - - -  
# *Parameters*  
# * [type:String] 事件类型  
# * [target:Object] 回调对象  
# * [method: String] 回调方法  
# * [arguments: Array] 绑定的参数，会展开并传递到回调方法的末尾参数  
# 
# 注意: 参数中的引用类型会增加引用计数，请使用弱引用传递值避免循环引用
# - - - - - - - - - -  
# *Returns* EventHandler  
# * 返回事件回调对象，可用于取消回调
func once(type, target: Object, method: String, arguments = []) -> Handler:
	var handler = self.on(type, target, method, arguments)
	handler.one_shot = true
	return handler

# 取消事件侦听  
# - - - - - - - - - -  
# *Parameters*  
# * [type:String] 事件类型  
# * [target:Object] 回调对象  
# * [method: String] 回调方法  
# - - - - - - - - - -  
# *Returns* Array<EventHandler> 
# * 返回成功解绑的所有回调对象
func off(type, target: Object, method: String) -> Array:
	var removals = []
	if type in _event_handlers:
		var handlers = _event_handlers[type]
		for h in handlers:
			if h.target == target:
				removals.append(h)
		for h in removals:
			handlers.erase(h)
	return removals

# 取消事件侦听  
# - - - - - - - - - -  
# *Parameters*  
# * [handler: EventHandler] 要取消的侦听器  
func off_handler(handler: EventHandler):
	if handler.type in _event_handlers:
		var handlers = _event_handlers[handler.type]
		if handler in handlers:
			handlers.erase(handler)

# 取消指定类型的所有事件侦听器  
# 如果传入 `null` 则清除所有事件的所有回调
func off_all(type = null):
	if type == null:
		_event_handlers = {}
	else:
		_event_handlers[type] = []
