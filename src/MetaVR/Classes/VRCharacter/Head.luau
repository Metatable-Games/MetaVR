
local Head = {}
Head.__index = Head

export type Head = {

} & typeof(setmetatable({}, Head))

function Head.new(HeadPart: BasePart): Head
    return setmetatable({}, Head)
end

function Head:GetAttachmentCFrame(Part: BasePart, AttachmentName: string): CFrame
    local Attachment = Part:FindFirstChild(AttachmentName)

    assert(Attachment ~= nil, "Attachment not found.")

    return Attachment and (Attachment :: Attachment).CFrame or CFrame.identity
end

function Head:GetEyesOffset(): CFrame
end

return Head