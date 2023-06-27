#define UPDATE_GRID 1
#include "GridCommon.hlsl"

void Update_Grid(inout VFXAttributes attributes, in float3 centerBox, in float3 sizeBox)
{
    uint2 currentGridPosition = GetGridPosition(attributes.position.xz, centerBox.xz, sizeBox.xz);
    if (attributes.alive)
    {
        CellData data;
        data.pos = attributes.position.xz;
        data.vel = attributes.velocity.xz;
        if (!TryInsertInCell(currentGridPosition, data))
        {
            //If a entity stays too long in a full cell, kill it.
            attributes.lifetime -= 0.1f;
        }
        else
        {
            attributes.lifetime = saturate(attributes.lifetime + 0.1f);
        }
    }
}
