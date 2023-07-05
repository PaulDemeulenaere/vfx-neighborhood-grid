#define CELL_CAPACITY 8
#define GRID_DIM 64

struct CellData
{
    float2 pos;
    float2 vel;
};

float2 InverseLerp(float2 A, float2 B, float2 V)
{
    return (V - A) / (B - A);
}

uint2 GetGridPosition(float2 pos, float2 centerBox, float2 sizeBox)
{
    float2 A = centerBox - sizeBox * 0.5f;
    float2 B = centerBox + sizeBox * 0.5f;
    float2 normalizedPos = InverseLerp(A, B, pos);
    uint2 uPos = floor(normalizedPos * (float2)GRID_DIM);
    return uPos;
}

uint GetGridLinearIndex(uint2 uPos)
{
    uPos = min(uPos, (uint2)GRID_DIM);
    return uPos.x * GRID_DIM + uPos.y;
}

#if UPDATE_GRID
RWStructuredBuffer<uint> Global_Grid_Count;
RWStructuredBuffer<CellData> Global_Grid_Data;

bool TryInsertInCell(uint2 uPos, CellData data)
{
    uint cellId = GetGridLinearIndex(uPos);
    uint index = 0;
    InterlockedAdd(Global_Grid_Count[cellId], 1, index);
    bool canAdd = index < CELL_CAPACITY;
    if (canAdd)
    {
        Global_Grid_Data[cellId * CELL_CAPACITY + index] = data;
    }
    return canAdd;
}

#elif READ_GRID
StructuredBuffer<uint> Global_Grid_Count;
StructuredBuffer<CellData> Global_Grid_Data;

uint GetCellCount(uint2 uPos)
{
    uint cellId = GetGridLinearIndex(uPos);
    return min(Global_Grid_Count[cellId], CELL_CAPACITY);
}

CellData GetCellData(uint2 uPos, uint index)
{
    uint cellId = GetGridLinearIndex(uPos);
    return Global_Grid_Data[cellId * CELL_CAPACITY + index];
}

#endif
