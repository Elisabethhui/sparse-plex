function result = ssc_l1_mahdi(X, D, K)
    options.num_clusters = K;
    result = spx.cluster.subspace.ssc_l1_mahdi(X, options);
end
