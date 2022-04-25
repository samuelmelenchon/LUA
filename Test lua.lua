

local t = {}

t[5] = 47
t[6] = 45
t[7] = 49

local sorted = {}
for k, v in pairs(t) do
    table.insert(sorted,{k,v})
end

table.sort(sorted, function(a,b) return a[2] < b[2] end)

for _, v in ipairs(sorted) do
    print(v[1],v[2])
end
