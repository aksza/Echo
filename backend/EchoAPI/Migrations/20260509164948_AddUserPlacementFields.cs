using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace EchoAPI.Migrations
{
    /// <inheritdoc />
    public partial class AddUserPlacementFields : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<DateTime>(
                name: "LevelAssessedAt",
                table: "Users",
                type: "datetime2",
                nullable: true);

            migrationBuilder.AddColumn<bool>(
                name: "PlacementCompleted",
                table: "Users",
                type: "bit",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<float>(
                name: "PlacementConfidence",
                table: "Users",
                type: "real",
                nullable: false,
                defaultValue: 0f);

            migrationBuilder.AddColumn<int>(
                name: "PlacementScore",
                table: "Users",
                type: "int",
                nullable: false,
                defaultValue: 0);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "LevelAssessedAt",
                table: "Users");

            migrationBuilder.DropColumn(
                name: "PlacementCompleted",
                table: "Users");

            migrationBuilder.DropColumn(
                name: "PlacementConfidence",
                table: "Users");

            migrationBuilder.DropColumn(
                name: "PlacementScore",
                table: "Users");
        }
    }
}
