'use client';

import { useState, useEffect } from 'react';
import { pipelinesApi, dealsApi, Pipeline, Deal } from '@/lib/api';

export default function PipelinesPage() {
  const [pipelines, setPipelines] = useState<Pipeline[]>([]);
  const [deals, setDeals] = useState<Deal[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    fetchData();
  }, []);

  const fetchData = async () => {
    try {
      setIsLoading(true);
      const [pipelinesData, dealsData] = await Promise.all([
        pipelinesApi.getAll(),
        dealsApi.getAll()
      ]);
      setPipelines(pipelinesData);
      setDeals(dealsData);
      setError(null);
    } catch (err) {
      setError('Failed to load data. Please check if the backend is running.');
    } finally {
      setIsLoading(false);
    }
  };

  const getDealsByPipeline = (pipelineId: number) => {
    return deals.filter(deal => deal.pipeline_id === pipelineId);
  };

  const getStatusColor = (status: string) => {
    const colors: Record<string, string> = {
      'lead': 'bg-gray-100 text-gray-800',
      'qualified': 'bg-blue-100 text-blue-800',
      'proposal': 'bg-yellow-100 text-yellow-800',
      'negotiation': 'bg-orange-100 text-orange-800',
      'won': 'bg-green-100 text-green-800',
      'lost': 'bg-red-100 text-red-800'
    };
    return colors[status] || 'bg-gray-100 text-gray-800';
  };

  if (isLoading) {
    return (
      <div className="flex justify-center items-center h-64">
        <div className="text-gray-600">Loading pipelines...</div>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <h1 className="text-3xl font-bold text-gray-900">Pipelines & Deals</h1>
      </div>

      {error && (
        <div className="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded">
          {error}
        </div>
      )}

      {pipelines.length === 0 ? (
        <div className="bg-white shadow rounded-lg p-8 text-center">
          <p className="text-gray-600">No pipelines yet. Use the AI Chat to create a pipeline!</p>
          <p className="text-sm text-gray-500 mt-2">
            Try: "Create a pipeline called Sales Pipeline"
          </p>
        </div>
      ) : (
        <div className="space-y-6">
          {pipelines.map(pipeline => {
            const pipelineDeals = getDealsByPipeline(pipeline.id);
            const totalValue = pipelineDeals.reduce((sum, deal) => sum + deal.value, 0);

            return (
              <div key={pipeline.id} className="bg-white shadow rounded-lg overflow-hidden">
                <div className="px-6 py-4 bg-gradient-to-r from-blue-600 to-blue-700">
                  <h2 className="text-xl font-semibold text-white">{pipeline.name}</h2>
                  {pipeline.description && (
                    <p className="text-blue-100 mt-1">{pipeline.description}</p>
                  )}
                  <div className="mt-2 text-sm text-blue-100">
                    {pipelineDeals.length} deals • Total value: ${totalValue.toLocaleString()}
                  </div>
                </div>

                <div className="p-6">
                  {pipelineDeals.length === 0 ? (
                    <p className="text-gray-500 text-center py-4">
                      No deals in this pipeline yet
                    </p>
                  ) : (
                    <div className="grid grid-cols-1 gap-4 md:grid-cols-2 lg:grid-cols-3">
                      {pipelineDeals.map(deal => (
                        <div key={deal.id} className="border border-gray-200 rounded-lg p-4 hover:shadow-md transition-shadow">
                          <div className="flex justify-between items-start mb-2">
                            <h3 className="font-semibold text-gray-900">{deal.title}</h3>
                            <span className={`px-2 py-1 rounded text-xs font-medium ${getStatusColor(deal.status)}`}>
                              {deal.status}
                            </span>
                          </div>
                          {deal.description && (
                            <p className="text-sm text-gray-600 mb-2">{deal.description}</p>
                          )}
                          <div className="flex justify-between items-center text-sm">
                            <span className="text-green-600 font-semibold">
                              ${deal.value.toLocaleString()}
                            </span>
                            <span className="text-gray-500">
                              Contact ID: {deal.contact_id}
                            </span>
                          </div>
                        </div>
                      ))}
                    </div>
                  )}
                </div>
              </div>
            );
          })}
        </div>
      )}
    </div>
  );
}
