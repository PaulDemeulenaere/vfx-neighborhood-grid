using System;
using System.Runtime.InteropServices;
using UnityEngine;

[ExecuteInEditMode]
public class GridManager : MonoBehaviour
{
    private static readonly int kGridDimension = 64;
    private static readonly int kCellCapacity = 8;
    private static readonly int kCellCount = kGridDimension * kGridDimension * kCellCapacity;
    private static readonly int kClearDispatchSize = kGridDimension * kGridDimension / 64;

    static readonly int kGlobal_NaiveGrid_CountID = Shader.PropertyToID("Global_NaiveGrid_Count");
    static readonly int kGlobal_NaiveGrid_DataID = Shader.PropertyToID("Global_NaiveGrid_Data");

    GraphicsBuffer m_NaiveGrid_Count;
    GraphicsBuffer m_NaiveGrid_Data;

    [SerializeField]
    ComputeShader m_GridClear;

    void OnEnable()
    {
        m_NaiveGrid_Count = new GraphicsBuffer(GraphicsBuffer.Target.Structured, kCellCount, Marshal.SizeOf(typeof(uint)));
        m_NaiveGrid_Data = new GraphicsBuffer(GraphicsBuffer.Target.Structured, kCellCount, Marshal.SizeOf(typeof(float)) * 4);
        
        Shader.SetGlobalBuffer(kGlobal_NaiveGrid_CountID, m_NaiveGrid_Count);
        Shader.SetGlobalBuffer(kGlobal_NaiveGrid_DataID, m_NaiveGrid_Data);
    }

    void Update()
    {
        m_GridClear?.Dispatch(0, kClearDispatchSize, 1, 1);
    }

    void OnDisable()
    {
        Shader.SetGlobalBuffer(kGlobal_NaiveGrid_CountID, (GraphicsBuffer)null);
        Shader.SetGlobalBuffer(kGlobal_NaiveGrid_DataID, (GraphicsBuffer)null);

        m_NaiveGrid_Count?.Release();
        m_NaiveGrid_Data?.Release();
    }
}