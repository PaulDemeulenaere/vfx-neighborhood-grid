#define CELL_CAPACITY 8
#define GRID_DIM 64

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

#if MISSING_CELL_DATA_DEFINITION
//Used for GridClear compute
struct CellData
{
    float2 pos;
    float2 vel;
};
#endif

bool TryInsertInCell(RWStructuredBuffer<CellData> gridData, RWStructuredBuffer<uint> gridCount, uint2 uPos, CellData data)
{
    uint cellId = GetGridLinearIndex(uPos);
    uint index = 0;
    InterlockedAdd(gridCount[cellId], 1, index);
    bool canAdd = index < CELL_CAPACITY;
    if (canAdd)
    {
        gridData[cellId * CELL_CAPACITY + index] = data;
    }
    return canAdd;
}

CellData GetCellData(StructuredBuffer<CellData> gridData, uint2 uPos, uint index)
{
    uint cellId = GetGridLinearIndex(uPos);
    return gridData[cellId * CELL_CAPACITY + index];
}

uint GetCellCount(StructuredBuffer<uint> gridCount, uint2 uPos)
{
    uint cellId = GetGridLinearIndex(uPos);
    return min(gridCount[cellId], CELL_CAPACITY);
}

