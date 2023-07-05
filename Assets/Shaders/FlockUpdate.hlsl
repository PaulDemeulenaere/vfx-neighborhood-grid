#define UPDATE_GRID 1
#include "GridCommon.hlsl"

void Update_Grid(inout VFXAttributes attributes, in float3 centerBox, in float3 sizeBox)
{
    if (attributes.alive)
    {
        CellData data = (CellData)0;
        data.pos = attributes.position.xz;
        data.vel = attributes.velocity.xz;
        uint2 gridPosition = GetGridPosition(attributes.position.xz, centerBox.xz, sizeBox.xz);
        if (TryInsertInCell(gridPosition, data))
        {
            attributes.lifetime = saturate(attributes.lifetime + 0.1f);
        }
        else
        {
            //If an entity stays too long in a full cell, kill it.
            attributes.lifetime -= 0.1f;
        }
    }
}
