extends RefCounted
class_name GxGamesPaginationData

## This object contains the pagination data for requests which get lists of items.

var currPage: int
var numPerPage: int
var totalItems: int
var totalPages: int

static var _props_names = [
	"currPage",
	"numPerPage",
	"totalItems",
	"totalPages"
]

static func from_dict(data_raw) -> GxGamesPaginationData:
	return GxParseUtils.try_fill_from_dict(
		GxGamesPaginationData.new(), 
		data_raw, 
		_props_names
	)
