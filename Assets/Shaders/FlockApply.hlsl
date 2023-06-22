#define READ_GRID 1
#include "GridCommon.hlsl"

bool GetNeighborhoodInfluence(float2 position, float3 centerBox, float3 sizeBox, out float2 cohesion, out float2 separation, out float2 alignement)
{
    float2 accumulatedAlignement;
    float2 accumulatedPosition;
    float2 accumulatedAvoidPosition = 0.0f;

    uint globalAvgCount = 0u;
    uint accumulatedAvoidPositionCount = 0u;

    float avoidThreshold = max(sizeBox.x, sizeBox.z)/GRID_DIM;
    avoidThreshold *= avoidThreshold;
    avoidThreshold = 0.3f; //TODOPAUL: Clean up compute

    uint2 currentGridPosition = GetGridPosition(position, centerBox.xz, sizeBox.xz);
    for (int i = -1; i <= 1; ++i)
    {
        for (int j = -1; j <= 1; ++j)
        {
            int2 gridPosition = (int2)currentGridPosition + int2(i, j);
            uint instanceCount = GetCellCount((uint2)gridPosition);
            for (uint instance = 0; instance < instanceCount; ++instance)
            {
                CellData data = GetCellData((uint2)gridPosition, instance);
                float2 positionVector = position - data.pos;
                float sqrLength = dot(positionVector, positionVector);

                accumulatedAlignement += data.vel;
                accumulatedPosition += data.pos;
                if (sqrLength < avoidThreshold && sqrLength > 0.001f)
                {
                    accumulatedAvoidPosition += position - data.pos;
                    accumulatedAvoidPositionCount++;
                }
                globalAvgCount++;
            }
        }
    }

    cohesion = separation = alignement = (float2)0.0f;

    if (globalAvgCount > 0)
    {
        accumulatedAlignement /= (float)globalAvgCount;
        accumulatedPosition /= (float)globalAvgCount;

        cohesion = accumulatedPosition - position;
        alignement = accumulatedAlignement;
    }

    if (accumulatedAvoidPositionCount > 0)
    {
        accumulatedAvoidPosition /= (float)accumulatedAvoidPositionCount;
        separation = accumulatedAvoidPosition;
    }

    return globalAvgCount > 0;
}

void Flock_Simulate(inout VFXAttributes attributes, in float3 centerBox, in float3 sizeBox, in float deltaTime)
{
    bool alive = attributes.alive;
    float2 cohesion, separation, alignement;
    bool valid = GetNeighborhoodInfluence(attributes.position.xz, centerBox, sizeBox, cohesion, separation, alignement);

    //WIP Some workaround to avoid multiple curly brace (see UUM-40706)
    if (alive && valid)
    {
        float flockCohesion = 6.0f;
        float flockAlignement = 3.0f;
        float flockSeparation = 15.0f;

        float2 velocity = attributes.velocity.xz;
        velocity = lerp(velocity, cohesion, saturate(deltaTime * flockCohesion));
        velocity = lerp(velocity, alignement, saturate(deltaTime * flockAlignement));
        velocity = lerp(velocity, velocity + separation, saturate(deltaTime * flockSeparation));

        attributes.velocity = float3(velocity.x, 0.0f, velocity.y);
	}
}

