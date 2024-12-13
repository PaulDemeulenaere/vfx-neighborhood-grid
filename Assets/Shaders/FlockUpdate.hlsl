#include "GridCommon.hlsl"

void Update_Grid(inout VFXAttributes attributes, RWStructuredBuffer<CellData> gridData, RWStructuredBuffer<uint> gridCount, float3 centerBox, float3 sizeBox)
{
    if (attributes.alive)
    {
        CellData data = (CellData)0;
        data.pos = attributes.position.xz;
        data.vel = attributes.velocity.xz;
        uint2 gridPosition = GetGridPosition(attributes.position.xz, centerBox.xz, sizeBox.xz);
        if (TryInsertInCell(gridData, gridCount, gridPosition, data))
        {
            attributes.age = saturate(attributes.age - 0.1f);
        }
        else
        {
            //If an entity stays too long in a full cell, slowly kill it.
            attributes.age += 0.1f;
        }
    }
}
