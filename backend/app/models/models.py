from typing import List, Optional
from datetime import datetime
from sqlalchemy import (
	String, Integer, Boolean, Numeric, Text, ForeignKey,
	CheckConstraint, text, DateTime
)
from sqlalchemy.orm import Mapped, mapped_column, relationship
from sqlalchemy.sql import func

# Importing the declarative base from database configuration
from app.db.database import Base


# ==========================================
# ASSOCIATION ORM MODELS
# ==========================================

class UserSubscription(Base):
	"""
	Association model representing a user following another user.
	"""
	__tablename__ = "user_subscriptions"

	subscriber_id: Mapped[int] = mapped_column(ForeignKey("users.id", ondelete="CASCADE"), primary_key=True)
	subscribed_user_id: Mapped[int] = mapped_column(ForeignKey("users.id", ondelete="CASCADE"), primary_key=True)
	created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())

	# --- Relationships ---
	# We must specify foreign_keys here because both point to the User table
	subscriber: Mapped["User"] = relationship(
		foreign_keys=[subscriber_id],
		back_populates="following_associations"
	)
	subscribed_to: Mapped["User"] = relationship(
		foreign_keys=[subscribed_user_id],
		back_populates="follower_associations"
	)


class GiftTag(Base):
	"""
	Association model linking gifts to tags.
	"""
	__tablename__ = "gift_tags"

	gift_id: Mapped[int] = mapped_column(ForeignKey("gifts.id", ondelete="CASCADE"), primary_key=True)
	tag_id: Mapped[int] = mapped_column(ForeignKey("tags.id", ondelete="CASCADE"), primary_key=True)

	# --- Relationships ---
	gift: Mapped["Gift"] = relationship(back_populates="gift_tags")
	tag: Mapped["Tag"] = relationship(back_populates="gift_tags")


class Booking(Base):
	"""
	Association model representing a user booking a specific gift.
	"""
	__tablename__ = "bookings"

	# unique=True prevents multiple users from booking the exact same gift
	gift_id: Mapped[int] = mapped_column(ForeignKey("gifts.id", ondelete="CASCADE"), primary_key=True, unique=True)
	user_id: Mapped[int] = mapped_column(ForeignKey("users.id", ondelete="CASCADE"), primary_key=True)
	created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())

	# --- Relationships ---
	gift: Mapped["Gift"] = relationship(back_populates="booking_info")
	user: Mapped["User"] = relationship(back_populates="bookings")


# ==========================================
# MAIN ORM MODELS
# ==========================================

class SubscriptionType(Base):
	__tablename__ = "subscription_types"

	id: Mapped[int] = mapped_column(primary_key=True)
	name: Mapped[str] = mapped_column(String(50), unique=True)
	description: Mapped[Optional[str]] = mapped_column(Text)

	# Back-populates: allows fetching all users holding this subscription type
	users: Mapped[List["User"]] = relationship(back_populates="subscription_type")


class User(Base):
	__tablename__ = "users"

	id: Mapped[int] = mapped_column(primary_key=True)
	username: Mapped[str] = mapped_column(String(50), unique=True, index=True) # 1. Unique username (e.g., 'sarahj_98')
	name: Mapped[str] = mapped_column(String(100), index=True) # 2. Display name (e.g., 'Sarah Jenkins')
	subscription_type_id: Mapped[int] = mapped_column(ForeignKey("subscription_types.id"))
	photo_url: Mapped[Optional[str]] = mapped_column(String(255))

	# Indexing email for fast O(log N) lookup during authentication
	email: Mapped[str] = mapped_column(String(255), unique=True, index=True)
	password_hash: Mapped[str] = mapped_column(String(255))
	created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())

	# Used to invalidate all existing JWT tokens instantly
	token_version: Mapped[int] = mapped_column(Integer, default=1, server_default=text("1"))

	# --- Relationships ---
	subscription_type: Mapped[Optional["SubscriptionType"]] = relationship(back_populates="users")

	# Cascade behavior: Deleting a user automatically deletes all their wishlists and tags
	wishlists: Mapped[List["Wishlist"]] = relationship(back_populates="owner", cascade="all, delete-orphan")
	created_tags: Mapped[List["Tag"]] = relationship(back_populates="creator", cascade="all, delete-orphan")

	# Links to the Booking association model
	bookings: Mapped[List["Booking"]] = relationship(back_populates="user", cascade="all, delete-orphan")

	# Self-referential associations for the follower system
	following_associations: Mapped[List["UserSubscription"]] = relationship(
		foreign_keys="[UserSubscription.subscriber_id]",
		back_populates="subscriber",
		cascade="all, delete-orphan"
	)
	follower_associations: Mapped[List["UserSubscription"]] = relationship(
		foreign_keys="[UserSubscription.subscribed_user_id]",
		back_populates="subscribed_to",
		cascade="all, delete-orphan"
	)


class Wishlist(Base):
	__tablename__ = "wishlists"

	id: Mapped[int] = mapped_column(primary_key=True)
	title: Mapped[str] = mapped_column(String(150))
	owner_id: Mapped[int] = mapped_column(ForeignKey("users.id", ondelete="CASCADE"))

	# Server default forces MySQL to set this to true (1) if no data is provided
	is_visible: Mapped[bool] = mapped_column(Boolean, default=True, server_default=text("1"))
	created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())

	# --- Relationships ---
	owner: Mapped["User"] = relationship(back_populates="wishlists")
	gifts: Mapped[List["Gift"]] = relationship(back_populates="wishlist", cascade="all, delete-orphan")


class Tag(Base):
	__tablename__ = "tags"

	id: Mapped[int] = mapped_column(primary_key=True)
	name: Mapped[str] = mapped_column(String(50))

	created_by_user_id: Mapped[int] = mapped_column(ForeignKey("users.id", ondelete="CASCADE"))
	description: Mapped[Optional[str]] = mapped_column(Text)

	# --- Relationships ---
	creator: Mapped["User"] = relationship(back_populates="created_tags")
	# Link to the GiftTag association model
	gift_tags: Mapped[List["GiftTag"]] = relationship(back_populates="tag", cascade="all, delete-orphan")


class Gift(Base):
	__tablename__ = "gifts"

	id: Mapped[int] = mapped_column(primary_key=True)
	name: Mapped[str] = mapped_column(String(150))
	price_usd: Mapped[float] = mapped_column(Numeric(10, 2))
	photo_url: Mapped[Optional[str]] = mapped_column(String(255))
	wishlist_id: Mapped[int] = mapped_column(ForeignKey("wishlists.id", ondelete="CASCADE"))
	link_url: Mapped[str] = mapped_column(String(500))
	is_visible: Mapped[bool] = mapped_column(Boolean, default=True, server_default=text("1"))
	description: Mapped[Optional[str]] = mapped_column(Text)
	created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())

	# Database-level constraint: Prevents insertion of negative or zero prices
	__table_args__ = (
		CheckConstraint("price_usd > 0", name="check_price_positive"),
	)

	# --- Relationships ---
	wishlist: Mapped["Wishlist"] = relationship(back_populates="gifts")

	# Links to the GiftTag association model
	gift_tags: Mapped[List["GiftTag"]] = relationship(back_populates="gift", cascade="all, delete-orphan")

	# uselist=False strictly enforces a One-to-One perspective.
	# One gift can only have one booking record.
	booking_info: Mapped[Optional["Booking"]] = relationship(back_populates="gift", uselist=False, cascade="all, delete-orphan")