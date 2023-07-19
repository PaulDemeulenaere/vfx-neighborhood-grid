#define READ_GRID 1
#include "GridCommon.hlsl"

void Grid_Debug(inout VFXAttributes attributes, in float3 centerBox, in float3 sizeBox)
{
    uint2 currentGridPosition = GetGridPosition(attributes.position.xz, centerBox.xz, sizeBox.xz);
    attributes.age = GetCellCount(currentGridPosition) / (float)CELL_CAPACITY;
}
