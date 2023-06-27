#define READ_GRID 1
#include "GridCommon.hlsl"

bool GetNeighborhoodInfluence(float2 position, float3 centerBox, float3 sizeBox, out float2 cohesion, out float2 separation, out float2 alignment)
{
    float2 accumulatedAlignement = 0.0f;
    float2 accumulatedPosition = 0.0f;
    float2 accumulatedAvoidPosition = 0.0f;

    uint globalAvgCount = 0u;
    uint accumulatedAvoidPositionCount = 0u;

    float avoidThreshold = max(sizeBox.x, sizeBox.z)/GRID_DIM;
    avoidThreshold *= avoidThreshold;
    avoidThreshold = 0.25f; //TODOPAUL: Clean up compute

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

                if (position.x != data.pos.x && position.y != data.pos.y) //float comparison is legit here, it skip the current instance
                {
                    float2 positionVector = position - data.pos;
                    float sqrLength = dot(positionVector, positionVector);

                    accumulatedAlignement += data.vel;
                    accumulatedPosition += data.pos;

                    float dampingAvoid = exp(-sqrLength * 50.0f);
                    accumulatedAvoidPosition += normalize(position - data.pos) * dampingAvoid;

                    globalAvgCount++;
                }
            }
        }
    }

    cohesion = separation = alignment = (float2)0.0f;

    accumulatedAlignement /= (float)globalAvgCount;
    accumulatedPosition /= (float)globalAvgCount;

    cohesion = accumulatedPosition - position;
    alignment = accumulatedAlignement;
	separation = accumulatedAvoidPosition;

    return globalAvgCount > 0;
}

void Flock_Simulate(inout VFXAttributes attributes, in float3 centerBox, in float3 sizeBox, in float deltaTime)
{
	if (attributes.alive)
    {
        float2 cohesion, separation, alignment;
        if (GetNeighborhoodInfluence(attributes.position.xz, centerBox, sizeBox, cohesion, separation, alignment))
        {
            float flockCohesion = 6.0f;
            float flockAlignment = 4.0f;
            float flockSeparation = 14.0f;

            float2 velocity = attributes.velocity.xz;
            velocity = lerp(velocity, separation, saturate(deltaTime * flockSeparation));
            velocity = lerp(velocity, alignment, saturate(deltaTime * flockAlignment));
            velocity = lerp(velocity, cohesion, saturate(deltaTime * flockCohesion));

            attributes.velocity = float3(velocity.x, 0.0f, velocity.y);
        }
	}
}

