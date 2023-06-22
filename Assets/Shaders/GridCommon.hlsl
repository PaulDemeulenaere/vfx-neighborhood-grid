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
RWStructuredBuffer<uint> Global_NaiveGrid_Count;
RWStructuredBuffer<CellData> Global_NaiveGrid_Data;

bool TryInsertInCell(uint2 uPos, CellData data)
{
    uint cellId = GetGridLinearIndex(uPos);
    uint index;
    InterlockedAdd(Global_NaiveGrid_Count[cellId], 1, index);
    if (index < CELL_CAPACITY)
    {
        Global_NaiveGrid_Data[cellId * CELL_CAPACITY + index] = data;
        return true;
    }
    return false;
}

#elif READ_GRID
StructuredBuffer<uint> Global_NaiveGrid_Count;
StructuredBuffer<CellData> Global_NaiveGrid_Data;

uint GetCellCount(uint2 uPos)
{
    uint cellId = GetGridLinearIndex(uPos);
    return min(Global_NaiveGrid_Count[cellId], CELL_CAPACITY);
}

CellData GetCellData(uint2 uPos, uint index)
{
    uint cellId = GetGridLinearIndex(uPos);
    return Global_NaiveGrid_Data[cellId * CELL_CAPACITY + index];
}

#endif
