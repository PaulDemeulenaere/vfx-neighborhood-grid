using System;
using System.Runtime.InteropServices;
using UnityEngine;
using UnityEngine.VFX;

namespace Flock.Sample
{
    [VFXType(VFXTypeAttribute.Usage.GraphicsBuffer)]
    struct CellData
    {
        public Vector2 pos;
        public Vector2 vel;
    }

    [ExecuteInEditMode]
    [RequireComponent(typeof(VisualEffect))]
    public class GridManager : MonoBehaviour
    {
        private static readonly int kGridDimension = 64;
        private static readonly int kCellCapacity = 8;
        private static readonly int kCellCount = kGridDimension * kGridDimension * kCellCapacity;
        private static readonly int kClearDispatchSize = kGridDimension * kGridDimension / 64;

        static readonly int kGridCountID = Shader.PropertyToID("GridCount");
        static readonly int kGridDataID = Shader.PropertyToID("GridData");

        GraphicsBuffer m_NaiveGrid_Count;
        GraphicsBuffer m_NaiveGrid_Data;

        VisualEffect m_VisualEffect;

        [SerializeField]
        ComputeShader m_GridClear;

        void OnEnable()
        {
            m_NaiveGrid_Count = new GraphicsBuffer(GraphicsBuffer.Target.Structured, kCellCount, Marshal.SizeOf(typeof(uint)));
            m_NaiveGrid_Data = new GraphicsBuffer(GraphicsBuffer.Target.Structured, kCellCount, Marshal.SizeOf(typeof(CellData)));

            m_VisualEffect = GetComponent<VisualEffect>();
            m_VisualEffect.SetGraphicsBuffer(kGridCountID, m_NaiveGrid_Count);
            m_VisualEffect.SetGraphicsBuffer(kGridDataID, m_NaiveGrid_Data);
        }

        void Update()
        {
            //This clear dispatch will be called before any VFX.Update
            m_GridClear?.SetBuffer(0, kGridCountID, m_NaiveGrid_Count);
            m_GridClear?.Dispatch(0, kClearDispatchSize, 1, 1);
        }

        void OnDisable()
        {
            m_VisualEffect.SetGraphicsBuffer(kGridCountID, null);
            m_VisualEffect.SetGraphicsBuffer(kGridDataID, null);

            m_NaiveGrid_Count?.Release();
            m_NaiveGrid_Data?.Release();
        }
    }
}