module LongPrint

using Comonicon

@cast function long_non_typed(;option="super long string super long string super long string")
end

@cast function long_typed(;option::String="super long string super long string super long string")
end

@main

end
