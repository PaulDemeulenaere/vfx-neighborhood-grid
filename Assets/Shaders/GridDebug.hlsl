#define MISSING_CELL_DATA_DEFINITION 1
#include "GridCommon.hlsl"

void Grid_Debug(inout VFXAttributes attributes, StructuredBuffer<uint> gridCount, in float3 centerBox, in float3 sizeBox)
{
    uint2 currentGridPosition = GetGridPosition(attributes.position.xz, centerBox.xz, sizeBox.xz);
    attributes.age = GetCellCount(gridCount, currentGridPosition) / (float) CELL_CAPACITY;
}
