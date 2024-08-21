@tool
extends MarginContainer

var _opera_adapter: OperaSdkFacade

@onready var http_request = $HTTPRequest

@onready var _update_button = $VBoxContainer/AuthorizationSection/VBoxContainer/HBoxContainer/Update
@onready var _auth_label = $VBoxContainer/AuthorizationSection/VBoxContainer/HBoxContainer/Label
@onready var _select_game_popup = $VBoxContainer/ProductInfoSection/VBoxContainer/SelectGame/MenuButton
@onready var _game_name = $VBoxContainer/ProductInfoSection/VBoxContainer/GameName/VBoxContainer/HBoxContainer/LineEdit
@onready var _game_name_warning = $VBoxContainer/ProductInfoSection/VBoxContainer/GameName/VBoxContainer/GameNameWarning
@onready var _version = $VBoxContainer/ProductInfoSection/VBoxContainer/Version
@onready var _next_version = $VBoxContainer/ProductInfoSection/VBoxContainer/NextVersion
@onready var _select_group_popup = $VBoxContainer/ProductInfoSection/VBoxContainer/SelectGroup/MenuButton 
@onready var _edit_url = $VBoxContainer/UrlButtonsSection/VBoxContainer/EditGameOnOpera
@onready var _internal_share_url = $VBoxContainer/UrlButtonsSection/VBoxContainer/InternalShareUrl
@onready var _public_share_url = $VBoxContainer/UrlButtonsSection/VBoxContainer/PublicShareUrl
@onready var _register_button = $VBoxContainer/ProductInfoSection/VBoxContainer/RegisterOnGxGames
@onready var _ui_blocker = $UiBlocker

func initialize(opera_adapter: OperaSdkFacade):
	_opera_adapter = opera_adapter	
	
	_update_button.initialize(_opera_adapter)
	_auth_label.initialize(_opera_adapter)
	_select_game_popup.initialize(_opera_adapter)
	_game_name.initialize(_opera_adapter)
	_game_name_warning.initialize(_opera_adapter)
	_version.update_state(_opera_adapter.Version, true)
	_next_version.update_state(_opera_adapter.NextVersion, false)
	_select_group_popup.initialize(_opera_adapter)
	_edit_url.initialize(_opera_adapter)
	_internal_share_url.initialize(_opera_adapter)
	_public_share_url.initialize(_opera_adapter)
	_register_button.initialize(_opera_adapter)

func on_process_started():
	_update_button.grab_focus()
	_ui_blocker.visible = true

func on_state_changed():
	_auth_label.update()
	_select_game_popup.update()
	_game_name.update()
	_game_name_warning.update_state()
	_version.update_state(_opera_adapter.Version, true)
	_next_version.update_state(_opera_adapter.NextVersion, false)
	_select_group_popup.update()
	_edit_url.update()
	_internal_share_url.update()
	_public_share_url.update()
	_register_button.update()
	_ui_blocker.visible = false

func _on_NextVersion_version_changed(new_version):
	_opera_adapter.NextVersion = new_version
