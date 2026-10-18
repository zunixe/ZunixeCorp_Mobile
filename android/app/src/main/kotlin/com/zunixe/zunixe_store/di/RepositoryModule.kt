package com.zunixe.zunixe_store.di

import com.zunixe.zunixe_store.feature.auth.data.AuthRepositoryImpl
import com.zunixe.zunixe_store.feature.auth.domain.AuthRepository
import com.zunixe.zunixe_store.feature.cart.data.CartRepositoryImpl
import com.zunixe.zunixe_store.feature.cart.domain.CartRepository
import com.zunixe.zunixe_store.feature.catalog.data.ProductRepositoryImpl
import com.zunixe.zunixe_store.feature.catalog.domain.ProductRepository
import com.zunixe.zunixe_store.feature.orders.data.OrderRepositoryImpl
import com.zunixe.zunixe_store.feature.orders.domain.OrderRepository
import dagger.Binds
import dagger.Module
import dagger.hilt.InstallIn
import dagger.hilt.components.SingletonComponent
import javax.inject.Singleton

@Module
@InstallIn(SingletonComponent::class)
abstract class RepositoryModule {

    @Binds
    @Singleton
    abstract fun bindProductRepository(impl: ProductRepositoryImpl): ProductRepository

    @Binds
    @Singleton
    abstract fun bindCartRepository(impl: CartRepositoryImpl): CartRepository

    @Binds
    @Singleton
    abstract fun bindOrderRepository(impl: OrderRepositoryImpl): OrderRepository

    @Binds
    @Singleton
    abstract fun bindAuthRepository(impl: AuthRepositoryImpl): AuthRepository
}
