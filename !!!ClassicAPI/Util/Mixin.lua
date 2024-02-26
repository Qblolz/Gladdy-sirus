local select = select

function Mixin(object, ...)
	for i = 1, select("#", ...) do
		local mixin = select(i, ...)
		if ( mixin ) then -- prevent errors on 3.3.5
			for k, v in pairs(mixin) do
				object[k] = v
			end
		end
	end
	return object
end

function CreateFromMixins(...)
	return Mixin({}, ...)
end

function CreateAndInitFromMixin(mixin, ...)
	local object = CreateFromMixins(mixin)
	object:Init(...)
	return object
end