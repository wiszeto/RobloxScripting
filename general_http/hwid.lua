local HttpService = game:GetService("HttpService")

if not http or not http.request then
    error("Http functionality is not available.")
end

local response = http.request({
    Url = "http://httpbin.org/headers",
    Method = "GET"
})

if not response or not response.Body then
    error("Invalid response or no Body found.")
end

-- Debugging: Print the raw response body
print("Response Body:", response.Body)

-- Attempt to decode JSON
local success, decodedResponse = pcall(function()
    return HttpService:JSONDecode(response.Body)
end)

if not success then
    error("Failed to decode JSON: " .. tostring(decodedResponse))
end

-- Access headers and handle missing keys
local hwid = decodedResponse.headers
hwid = hwid["Syn-Fingerprint"] or hwid["Sw-Fingerprint"] or "Fingerprint not found"

print(hwid)
