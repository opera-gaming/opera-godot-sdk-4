extends RefCounted
class_name GxParseUtils

# Tryes to parse a raw data using from_dict.
# if data_raw is not an array or parsing of any item is not successful
# the function returns an empty array.
static func from_raw_to_array(data_raw, from_dict: Callable) -> Array:
	if data_raw is Array:
		var result = data_raw.map(from_dict)
		if result.all(func(item): return item != null):
			return result
	
	return []

# Tryes to fill the fields of the provided instance from the dictionary data_raw.
# If it is successful it returns the instance. If it is not the function returns
# null.
# The funtion may parse only plain data types (e.g. String, int etc).
static func try_fill_from_dict(instance, data_raw, props_names):
	if data_raw is Dictionary:
		for prop_name in props_names:
			if !data_raw.has(prop_name):
				return null
			
			instance.set(prop_name, data_raw[prop_name])
		
		return instance
	
	return null
